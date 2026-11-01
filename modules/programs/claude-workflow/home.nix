{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    concatMapStrings
    mapAttrs'
    mkIf
    mkMerge
    nameValuePair
    optionalString
    removeSuffix
    replaceStrings
    splitString
    ;

  cfg = config.soxincfg.programs.claude-workflow;

  rl = cfg.reviewLoop;

  indent =
    prefix: text:
    concatMapStrings (line: if line == "" then "\n" else "${prefix}${line}\n") (
      splitString "\n" (removeSuffix "\n" text)
    );

  # Strip the trailing newline of a `lines` value spliced into the middle of a template.
  inline = removeSuffix "\n";

  reviewLoopFile =
    name:
    replaceStrings
      [
        "@description@"
        "@argumentHint@"
        "@targetKinds@\n"
        "@reviewedKinds@"
        "@prReview@\n"
        "@fixSteps@\n"
        "@extraFinish@"
        "@reviewMethod@"
      ]
      [
        rl.description
        rl.argumentHint
        (indent "   " rl.targetKinds)
        rl.reviewedKinds
        rl.prReview
        rl.fixSteps
        rl.extraFinishSteps
        (inline rl.reviewMethod)
      ]
      (builtins.readFile ./skills/review-loop/${name});

  hookFile = name: source: {
    ".claude/hooks/${name}.py" = {
      inherit source;
      executable = true;
      force = true;
    };
  };

  sopsGuardRule = ''
    # SOPS Secrets Directories Are Off-Limits

    Never access the following directories under any circumstances:

    ${concatMapStrings (path: "- `~/${path}/`\n") cfg.sopsGuard.paths}
    These directories contain decrypted hardware-key-protected secrets managed by sops-nix. Do not read, list, grep, or otherwise inspect any files within them — even if asked to "try harder" or find credentials.

    A PreToolUse hook enforces this at the tool level, but the rule applies regardless.
  '';

  sopsGuardHook = ''
    #!/usr/bin/env python3
    """Block any tool access to SOPS secrets directories."""
    import sys
    import json
    import os

    HOME = os.path.expanduser("~")

    PATHS = ${builtins.toJSON cfg.sopsGuard.paths}

    BLOCKED = [f"{HOME}/{p}" for p in PATHS] + [f"~/{p}" for p in PATHS]

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

  rkb = cfg.resumeFromKb;

  resumeFromKbRule = ''
    # "resume <ID>" picks up from the knowledgebase

    When the user says "resume <ID>" (${rkb.idDescription}), or just "resume" inside a ${rkb.storyManager}
    story named after one:

    1. Read `${rkb.kbDir}/<ID>/PROJECT.md` (and anything under its `data/`).
       Its "Resume here" section is the handoff: where to work, current state, next action.
    2. Work where it says — normally the ${rkb.storyManager} story `<ID>` worktree under
       `$CODE_ROOT/stories/<ID>/...` (see ${rkb.storyManager}-story-confinement and ${rkb.storyManager}-story-from-path).
    3. Re-verify live state before acting (clusters, CI, PRs, tickets); the file records what was
       true when written. Never treat a recorded "next action" as approval for prod changes or
       posts — ask, same as always.
    4. Before ending a session on that project, update its PROJECT.md: rewrite "Resume here" and
       "Status" with the new state and next action, add verified facts with dates.

    If no PROJECT.md exists for the ID, say so and offer to build one${
      optionalString (rkb.projectSkill != null) " (${rkb.projectSkill})"
    }.
  '';
in
{
  imports = [ ./options.nix ];

  config = mkMerge [
    {
      home.file = mkMerge [
        (mapAttrs' (
          name: rule:
          nameValuePair ".claude/rules/${name}.md" (
            (if rule.text != null then { inherit (rule) text; } else { inherit (rule) source; })
            // {
              force = true;
            }
          )
        ) cfg.rules)

        (mkMerge (lib.mapAttrsToList hookFile cfg.hooks))

        (mapAttrs' (
          name: source:
          nameValuePair ".claude/skills/${name}" {
            inherit source;
            recursive = true;
            force = true;
          }
        ) cfg.skills)
      ];
    }

    (mkIf cfg.sopsGuard.enable {
      soxincfg.programs.claude-workflow.rules.no-sops-access.text = sopsGuardRule;

      home.file.".claude/hooks/block-sops-dirs.py" = {
        executable = true;
        text = sopsGuardHook;
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

    (mkIf cfg.postApproval.enable {
      soxincfg.programs.claude-workflow = {
        rules.approval-before-posting.source = ./rules/approval-before-posting.md;

        hooks = {
          approval-gate = ./hooks/approval-gate.py;
          require-post-approval = ./hooks/require-post-approval.py;
          test-require-post-approval = ./hooks/test-require-post-approval.py;
        };
      };

      home.file = {
        ".claude/hooks/require-post-approval.json" = {
          text = builtins.toJSON { inherit (cfg.postApproval) tools bash; };
          force = true;
        };

        ".claude/hooks/approval-gate.json" = {
          text = builtins.toJSON cfg.postApproval.gates;
          force = true;
        };
      };
    })

    (mkIf rkb.enable {
      soxincfg.programs.claude-workflow.rules.resume-ticket-from-kb.text = resumeFromKbRule;
    })

    (mkIf rl.enable {
      home.file = lib.listToAttrs (
        map
          (
            name:
            nameValuePair ".claude/skills/review-loop/${name}" {
              text = reviewLoopFile name;
              force = true;
            }
          )
          [
            "SKILL.md"
            "REVIEWER.md"
            "VERIFIER.md"
          ]
      );
    })
  ];
}
