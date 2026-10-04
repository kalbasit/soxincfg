{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.soxincfg.programs.claude-code;

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

    # Deduplicated, so a plugin named twice is enabled once.
    plugins = lib.unique cfg.plugins;
  };

  # A script rather than inline activation text. Inline it worked, but it had
  # grown to a hundred lines of shell embedded in a Nix string, where nothing
  # checks it and a typo is found by the next host to activate. As a derivation
  # it is shellcheck'd on every build, and it can be run directly against a
  # throwaway HOME -- which is how the three bugs before this one were finally
  # pinned down, each after a rebuild that could have checked it first.
  reconcileMarketplaces = pkgs.writeShellApplication {
    name = "claude-code-reconcile-marketplaces";
    runtimeInputs = [
      pkgs.jq
      pkgs.git
      pkgs.openssh
      config.programs.claude-code.package
    ];
    text = ''
      desired="$1"
      dropped="$2"
      registry="$HOME/.claude/plugins/known_marketplaces.json"
      installed="$HOME/.claude/plugins/installed_plugins.json"

      # Taking an entry out of settings.json is not the same as removing it.
      # Claude Code keeps an installed plugin in installed_plugins.json and its
      # cache, and a marketplace in known_marketplaces.json, after both have
      # left settings.json -- so a plugin this module stops wanting would stay
      # on disk, hooks and all, with nothing declarative left to say why.
      #
      # Only what this module added and no longer wants is passed here, never
      # anything enabled by hand. Plugins go before marketplaces: removing a
      # marketplace first leaves its plugins with no source to uninstall from.
      if [[ -f "$installed" ]] && jq -e . "$installed" > /dev/null 2>&1; then
        while read -r spec; do
          [[ -n "$spec" ]] || continue
          jq -e --arg s "$spec" '.plugins[$s] != null' "$installed" > /dev/null || continue
          echo "claude-code: uninstalling $spec, which this configuration no longer wants"
          claude plugin uninstall "$spec" ||
            echo "claude-code: could not uninstall $spec; run 'claude plugin uninstall $spec' by hand" >&2
        done < <(jq -r '.plugins[]' "$dropped")
      fi

      if [[ -f "$registry" ]] && jq -e . "$registry" > /dev/null 2>&1; then
        while read -r name; do
          [[ -n "$name" ]] || continue
          jq -e --arg n "$name" 'has($n)' "$registry" > /dev/null || continue
          echo "claude-code: removing marketplace '$name', which this configuration no longer wants"
          claude plugin marketplace remove "$name" ||
            echo "claude-code: could not remove marketplace '$name'; run 'claude plugin marketplace remove $name' by hand" >&2
        done < <(jq -r '.marketplaces[]' "$dropped")
      fi

      # Claude Code keys its marketplace registry by *name*, and never revisits
      # the repository behind a name it already knows. So when a plugin moves
      # house, settings.json follows it and nothing else does: the registry
      # keeps cloning the old repository and the host runs code from somewhere
      # nobody maintains, while every declarative file on it says otherwise.
      #
      # Measured on code-01 2026-09-20, when a plugin moved to another
      # repository. `marketplace update` is no help: it pulls the clone it
      # already has, which is still the old repository. Re-adding is Claude
      # Code's own way of moving a name -- it re-clones, keeps the name so
      # plugin ids never change, and is a no-op when already correct.
      if [[ -f "$registry" ]] && jq -e . "$registry" > /dev/null 2>&1; then
        while read -r name was repo; do
          [[ -n "$name" ]] || continue
          echo "claude-code: repointing marketplace '$name' from $was to $repo"
          claude plugin marketplace add "$repo" ||
            echo "claude-code: could not repoint '$name'; run 'claude plugin marketplace add $repo' by hand" >&2
        done < <(jq -r --slurpfile d "$desired" '
            ($d[0].marketplaces) as $m
            | to_entries[]
            | select($m[.key] != null)
            | select(.value.source.repo != $m[.key].source.repo)
            | "\(.key) \(.value.source.repo) \($m[.key].source.repo)"
          ' "$registry")
      fi

      # Refreshing a marketplace is not the same as updating the plugin that
      # came from it, and Claude Code tracks the two separately. The clone
      # moves; installed_plugins.json goes on naming the version it installed
      # before -- and that record is what the hooks import and what a
      # wrapper around the plugin execs. Measured on the same host: registry and
      # plugin cache both reached 0.2.23 while installed_plugins.json stayed on
      # 0.2.22, so the machine had the new plugin on disk and ran the old one.
      #
      # Deliberately not nested inside the repoint above. By then the repoint
      # has usually already happened -- that host had a correct marketplace and
      # a stale plugin -- so a version left behind has to be its own check or it
      # is never reached.
      #
      # Which version is wanted is read from the clone on disk, so an ordinary
      # rebuild reaches the network only when there is something to install.
      if [[ -f "$installed" ]] && jq -e . "$installed" > /dev/null 2>&1; then
        while read -r spec; do
          [[ -n "$spec" ]] || continue
          plugin="''${spec%@*}"
          marketplace="''${spec#*@}"
          clone="$HOME/.claude/plugins/marketplaces/$marketplace"
          [[ -f "$clone/.claude-plugin/marketplace.json" ]] || continue

          entry=$(jq -r --arg n "$plugin" '.plugins[] | select(.name == $n) | .source // empty' \
            "$clone/.claude-plugin/marketplace.json")
          [[ -n "$entry" ]] || continue

          advertised=$(jq -r '.version // empty' \
            "$clone/$entry/.claude-plugin/plugin.json" 2> /dev/null || true)
          [[ -n "$advertised" ]] || continue

          current=$(jq -r --arg s "$spec" '.plugins[$s][0].version // empty' "$installed")
          [[ "$advertised" != "$current" ]] || continue

          echo "claude-code: updating $spec from ''${current:-nothing} to $advertised"
          claude plugin update "$spec" ||
            echo "claude-code: could not update $spec; run 'claude plugin update $spec' by hand" >&2
        done < <(jq -r '.plugins[]' "$desired")
      fi
    '';
  };

  desiredFile = pkgs.writeText "claude-code-desired.json" (builtins.toJSON desired);
in
{
  imports = [
    (import ../../agent/skills {
      inherit (cfg.skills) enable;

      addSkill = name: body: {
        home.file.".claude/skills/${name}/SKILL.md".text = body;
      };
    })
  ];

  config = lib.mkMerge [
    # Marketplaces and plugin enablement.
    #
    # Claude Code owns settings.json and its own plugin cache, so this module does
    # not write either. It states an intent and merges it in, additively. What was
    # enabled by hand on a machine stays enabled; what this module added is recorded
    # in a managed-set file so that dropping an entry here disables it again without
    # touching anything a human turned on.
    #
    # Runs whenever claude-code is enabled, not only while something is wanted:
    # a host whose last managed plugin was dropped is exactly the host that
    # has something left to remove.
    (lib.mkIf cfg.enable {
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
          # What we added last time and no longer want, computed before the
          # managed set below is overwritten with the new one.
          dropped=$(mktemp)
          ${pkgs.jq}/bin/jq -n \
            --slurpfile desired ${desiredFile} \
            --slurpfile managed "$managed" '
              ($desired[0]) as $d
              | ($managed[0]) as $m
              | {
                  marketplaces: [ $m.marketplaces[] | select(IN($d.marketplaces | keys[]) | not) ],
                  plugins: [ $m.plugins[] | select(IN($d.plugins[]) | not) ]
                }
            ' > "$dropped"

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

          ${lib.getExe reconcileMarketplaces} ${desiredFile} "$dropped"
          rm -f "$dropped"
        fi
      '';
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
