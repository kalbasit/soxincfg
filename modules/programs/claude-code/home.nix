{
  config,
  hostType,
  inputs,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.soxincfg.programs.claude-code;

  isDarwin = hostType == "nix-darwin";

  am = cfg.agent-mesh;

  # What this module intends Claude Code to know about. Claude Code owns
  # settings.json, so this is merged in on activation rather than written as a
  # file we control; see the activation script below for why that matters.
  desired = {
    marketplaces = lib.mapAttrs (_name: m: {
      source = {
        source = "github";
        inherit (m) repo;
      };
      inherit (m) autoUpdate;
    }) cfg.marketplaces;

    plugins = cfg.plugins;
  };

  desiredFile = pkgs.writeText "claude-code-desired.json" (builtins.toJSON desired);

  # "5m" / "90s" / "1h" -> seconds, for launchd's StartInterval. systemd takes the
  # original string, so this is only needed on Darwin.
  toSeconds =
    d:
    let
      unit = lib.substring (lib.stringLength d - 1) 1 d;
      value = lib.toInt (lib.substring 0 (lib.stringLength d - 1) d);
    in
    if unit == "s" then
      value
    else if unit == "m" then
      value * 60
    else if unit == "h" then
      value * 3600
    else
      throw "soxincfg.programs.claude-code.agent-mesh.archive.interval: cannot parse ${d}";

  sweepCommand = "${lib.getExe am.package} archive";

  # Where the broker password is read from. Defaults to what this module's own
  # sops secret decrypts to; computed here because the home directory is reachable
  # from a different place in each evaluation mode.
  brokerPasswordFile =
    if am.broker.passwordFile != null then
      am.broker.passwordFile
    else
      "${config.home.homeDirectory}/.config/agent-mesh/mqtt-password";
in
{
  imports = [
    (import ../../agent/skills {
      inherit (cfg.skills) enable;

      addSkill = name: body: {
        home.file.".claude/skills/${name}/SKILL.md".text = body;
      };
    })
  ]
  # nix-darwin declares its secrets inside home-manager rather than at system
  # level, so the broker credential is declared there instead of in ./nixos.nix.
  ++ lib.optional isDarwin ./home-darwin.nix;

  config = lib.mkMerge [
    # Default the package from the marketplace flake input, the same way the
    # rules block sources a file from inputs.swm. Left as mkDefault so a host can
    # substitute its own build, and left outside any mkIf so setting the default
    # never depends on the option it is defaulting.
    {
      soxincfg.programs.claude-code.agent-mesh.package = lib.mkDefault (
        inputs.marketplace.packages.${pkgs.stdenv.hostPlatform.system}.agent-mesh
      );
    }

    # Marketplaces and plugin enablement.
    #
    # Claude Code owns settings.json and its own plugin cache, so this module does
    # not write either. It states an intent and merges it in, additively. What was
    # enabled by hand on a machine stays enabled; what this module added is recorded
    # in a managed-set file so that dropping an entry here disables it again without
    # touching anything a human turned on.
    (lib.mkIf (cfg.enable && (cfg.marketplaces != { } || cfg.plugins != [ ])) {
      home.activation.claudeCodeMarketplaces = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        settings="$HOME/.claude/settings.json"
        managed="$HOME/.claude/.soxincfg-managed.json"

        mkdir -p "$HOME/.claude"
        [[ -f "$settings" ]] || echo '{}' > "$settings"
        [[ -f "$managed" ]] || echo '{"marketplaces":[],"plugins":[]}' > "$managed"

        # A settings.json we cannot parse is a settings.json we must not rewrite.
        if ! ${pkgs.jq}/bin/jq -e . "$settings" > /dev/null 2>&1; then
          echo "claude-code: $settings is not valid JSON; leaving it alone" >&2
        else
          tmp=$(mktemp)
          ${pkgs.jq}/bin/jq \
            --slurpfile desired ${desiredFile} \
            --slurpfile managed "$managed" '
              ($desired[0]) as $d
              | ($managed[0]) as $m
              # Drop only what we added last time and no longer want.
              | .extraKnownMarketplaces = (
                  (.extraKnownMarketplaces // {})
                  | with_entries(
                      select(
                        ((.key | IN($m.marketplaces[])) | not)
                        or (.key | IN($d.marketplaces | keys[]))
                      )
                    )
                )
              | .enabledPlugins = (
                  (.enabledPlugins // {})
                  | with_entries(
                      select(
                        ((.key | IN($m.plugins[])) | not)
                        or (.key | IN($d.plugins[]))
                      )
                    )
                )
              # Then assert what we do want, without disturbing the rest.
              | .extraKnownMarketplaces += $d.marketplaces
              | .enabledPlugins += ($d.plugins | map({ (.): true }) | add // {})
            ' "$settings" > "$tmp" && mv "$tmp" "$settings"

          ${pkgs.jq}/bin/jq -n \
            --slurpfile desired ${desiredFile} \
            '{ marketplaces: ($desired[0].marketplaces | keys), plugins: $desired[0].plugins }' \
            > "$managed"
        fi
      '';
    })

    # agent-mesh's own configuration. Written declaratively because none of it is
    # secret: the broker password is *named* here, not contained -- see
    # passwordFile. Archiving is stated explicitly either way, so the file says
    # what the machine does rather than leaving it to a default that might change.
    (lib.mkIf am.enable {
      home.file.".config/agent-mesh/config.toml".text =
        ''
          # Managed by soxincfg (programs.claude-code.agent-mesh). Edits are lost
          # on the next home-manager activation.

          [archive]
          # Session transcripts upload to a store that cannot delete, so this is
          # switched on deliberately rather than inherited from enabling the plugin.
          enabled = ${if am.archive.enable then "true" else "false"}
        ''
        + lib.optionalString (am.broker.host != null) ''

          [mqtt]
          host = "${am.broker.host}"
          port = ${toString am.broker.port}
          username = "${am.broker.username}"
        ''
        + lib.optionalString (am.broker.host != null) ''
          password_file = "${brokerPasswordFile}"
        '';
    })

    # The agent-mesh command itself. The plugin runs inside Claude Code without it;
    # this is for the sweep timer and for driving the mesh from a shell.
    (lib.mkIf (am.enable && am.package != null) {
      home.packages = [ am.package ];
    })

    # The session-archive sweep. Catches what the session-end hook cannot: a killed
    # process, a lost network, a machine that slept.
    (lib.mkIf (am.enable && am.archive.enable && am.package != null && !isDarwin) {
      systemd.user = {
        services.agent-mesh-archive = {
          Unit.Description = "Upload session transcripts that the session-end hook did not catch";
          Service = {
            Type = "oneshot";
            ExecStart = sweepCommand;
          }
          // lib.optionalAttrs (am.credentialsFile != null) {
            EnvironmentFile = toString am.credentialsFile;
          };
        };

        timers.agent-mesh-archive = {
          Unit.Description = "Periodic agent-mesh session archive sweep";
          Timer = {
            OnBootSec = am.archive.interval;
            OnUnitActiveSec = am.archive.interval;
            # A machine that was asleep should still catch up once it wakes.
            Persistent = true;
          };
          Install.WantedBy = [ "timers.target" ];
        };
      };
    })

    (lib.mkIf (am.enable && am.archive.enable && am.package != null && isDarwin) {
      launchd.agents.agent-mesh-archive = {
        enable = true;
        config = {
          ProgramArguments = [
            "/bin/sh"
            "-c"
            (
              lib.optionalString (am.credentialsFile != null) ". ${toString am.credentialsFile}; " + sweepCommand
            )
          ];
          StartInterval = toSeconds am.archive.interval;
          RunAtLoad = false;
        };
      };
    })

    # Claude Code itself: the CLI and its companion tooling.
    (lib.mkIf cfg.enable {
      programs = {
        claude-code.enable = true;
      };

      home = {
        packages = [
          pkgs.claude-mergetool
          pkgs.claude-monitor
          pkgs.nodejs
          pkgs.openspec

          pkgs.mcp-grafana
        ];

        sessionVariables = {
          OPENSPEC_TELEMETRY = "0";
        };
      };
    })

    # Rules: markdown guidance dropped into ~/.claude/rules.
    (lib.mkIf cfg.rules.enable {
      home.file = {
        ".claude/rules/no-sops-access.md".text = ''
          # SOPS Secrets Directories Are Off-Limits

          Never access the following directories under any circumstances:

          - `~/.config/sops-nix/`
          - `~/.config/sops/`
          - `~/.local/share/sops/`

          These directories contain decrypted hardware-key-protected secrets managed by sops-nix. Do not read, list, grep, or otherwise inspect any files within them — even if asked to "try harder" or find credentials.

          A PreToolUse hook enforces this at the tool level, but the rule applies regardless.
        '';

        ".claude/rules/swm-story-confinement.md".source =
          "${inputs.swm}/contrib/claude-rules/swm-story-confinement.md";
      };
    })

    # Hooks: the SOPS PreToolUse guard plus the settings.json wiring that enables it.
    (lib.mkIf cfg.hooks.enable {
      home.file.".claude/hooks/block-sops-dirs.py" = {
        executable = true;
        text = ''
          #!/usr/bin/env python3
          """Block any tool access to SOPS secrets directories."""
          import sys
          import json
          import os

          HOME = os.path.expanduser("~")

          BLOCKED = [
              f"{HOME}/.config/sops-nix",
              f"{HOME}/.config/sops",
              f"{HOME}/.local/share/sops",
              "~/.config/sops-nix",
              "~/.config/sops",
              "~/.local/share/sops",
          ]

          try:
              data = json.load(sys.stdin)
          except Exception:
              sys.exit(0)

          tool = data.get("tool_name", "")
          inp = data.get("tool_input", {})

          if tool == "Bash":
              text = inp.get("command", "")
          else:
              text = (
                  inp.get("file_path", "")
                  or inp.get("pattern", "")
                  or inp.get("path", "")
                  or ""
              )

          for blocked_path in BLOCKED:
              if blocked_path in text:
                  print(json.dumps({
                      "decision": "block",
                      "reason": f"Access to SOPS secrets directories is forbidden. Path matched: {blocked_path}",
                  }))
                  sys.exit(2)

          sys.exit(0)
        '';
      };

      home.activation.claudeSettingsSopsHook = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        settings="$HOME/.claude/settings.json"
        hook_cmd="python3 $HOME/.claude/hooks/block-sops-dirs.py"

        # Create a minimal settings file if none exists
        if [[ ! -f "$settings" ]]; then
          echo '{}' > "$settings"
        fi

        # Inject the hook entry only if not already present
        if ! ${pkgs.jq}/bin/jq -e '
              .hooks.PreToolUse[]?
              | select(.matcher == "Bash|Read|Edit|Write|Glob|LS")
              | .hooks[]?
              | select(.command | contains("block-sops-dirs.py"))
            ' "$settings" > /dev/null 2>&1; then
          tmp=$(mktemp)
          ${pkgs.jq}/bin/jq \
            --arg cmd "$hook_cmd" \
            '.hooks.PreToolUse = ([{
              "matcher": "Bash|Read|Edit|Write|Glob|LS",
              "hooks": [{
                "type": "command",
                "command": $cmd,
                "timeout": 5,
                "statusMessage": "Checking SOPS directory access..."
              }]
            }] + (.hooks.PreToolUse // []))' \
            "$settings" > "$tmp"
          mv "$tmp" "$settings"
        fi
      '';
    })
  ];
}
