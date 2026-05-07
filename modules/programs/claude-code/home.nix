{
  config,
  hostType,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.soxincfg.programs.claude-code;
in
{
  imports = [
    (import ../../agent/skills {
      inherit (cfg) enable;

      addSkill = name: body: {
        home.file.".claude/skills/${name}/SKILL.md".text = body;
      };
    })
  ];

  config = lib.mkIf cfg.enable {
    programs = {
      claude-code.enable = true;
    };

    home = {
      packages = [
        pkgs.claude-mergetool
        pkgs.claude-monitor
        pkgs.nodejs
        pkgs.openspec
      ];

      sessionVariables = {
        OPENSPEC_TELEMETRY = "0";
      };

      file = {
        ".claude/hooks/block-sops-dirs.py" = {
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

        ".claude/rules/no-sops-access.md".text = ''
          # SOPS Secrets Directories Are Off-Limits

          Never access the following directories under any circumstances:

          - `~/.config/sops-nix/`
          - `~/.config/sops/`
          - `~/.local/share/sops/`

          These directories contain decrypted hardware-key-protected secrets managed by sops-nix. Do not read, list, grep, or otherwise inspect any files within them — even if asked to "try harder" or find credentials.

          A PreToolUse hook enforces this at the tool level, but the rule applies regardless.
        '';
      };

      activation.claudeSettingsSopsHook = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
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
    };
  };
}
