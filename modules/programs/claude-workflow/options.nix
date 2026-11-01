{ config, lib, ... }:

let
  inherit (lib) mkEnableOption mkOption types;

  cfg = config.soxincfg.programs.claude-workflow;

  inherit (types) lines;
in
{
  options.soxincfg.programs.claude-workflow = {
    rules = mkOption {
      type = types.attrsOf (
        types.submodule {
          options = {
            text = mkOption {
              type = types.nullOr lines;
              default = null;
              description = "Text of the rule.";
            };

            source = mkOption {
              type = types.nullOr types.path;
              default = null;
              description = "File holding the rule.";
            };
          };
        }
      );
      default = { };
      description = "Extra Claude Code rules, installed as `~/.claude/rules/<name>.md`.";
    };

    hooks = mkOption {
      type = types.attrsOf types.path;
      default = { };
      description = "Extra hook scripts, installed executable as `~/.claude/hooks/<name>.py`.";
    };

    skills = mkOption {
      type = types.attrsOf types.path;
      default = { };
      description = "Extra skill directories, installed as `~/.claude/skills/<name>`.";
    };

    sopsGuard = {
      enable = mkEnableOption ''
        a rule and a PreToolUse hook that keep Claude Code out of decrypted SOPS directories.
        The hook is added to `~/.claude/settings.json` on activation'';

      paths = mkOption {
        type = types.listOf types.str;
        default = [
          ".config/sops-nix"
          ".config/sops"
          ".local/share/sops"
        ];
        description = "Directories, relative to the home directory, that Claude must never access.";
      };
    };

    postApproval = {
      enable = mkEnableOption ''
        the approval-before-posting rule and two PreToolUse hook scripts (approval-gate.py
        and require-post-approval.py) that deny a post unless the user's own latest message
        approves it. The hooks are installed but not wired into settings.json'';

      tools = mkOption {
        type = types.listOf types.str;
        default = [ ];
        example = [ "mcp__example__publish" ];
        description = "MCP tools that publish and require approval (require-post-approval.py).";
      };

      bash = mkOption {
        type = types.listOf (
          types.submodule {
            options = {
              pattern = mkOption {
                type = types.str;
                description = "Python regex searched in a Bash command.";
              };
              label = mkOption {
                type = types.str;
                description = "Name of the action, shown when it is blocked.";
              };
            };
          }
        );
        default = [ ];
        description = "Extra shell commands that publish, beyond the built-in `gh` comment patterns.";
      };

      gates = mkOption {
        type = types.listOf (types.attrsOf types.anything);
        default = [ ];
        example = [
          {
            name = "protected draft";
            match = [ "request.md" ];
            phrase = "operation approved";
          }
        ];
        description = ''
          Extra phrase gates for approval-gate.py, beyond the built-in Slack gate. Each takes
          `name`, `phrase` and any of `tools` (regex), `bash` (regexes) and `match` (substrings).
        '';
      };
    };

    resumeFromKb = {
      enable = mkEnableOption ''a rule that makes "resume <ID>" pick up a project from its notes'';

      kbDir = mkOption {
        type = types.str;
        default = "~/.claude/knowledgebase/projects";
        description = "Directory holding one `<ID>/PROJECT.md` per project.";
      };

      idDescription = mkOption {
        type = types.str;
        default = "a ticket or project key";
        description = "How the rule describes a project ID.";
      };

      storyManager = mkOption {
        type = types.str;
        default = "swm";
        description = "Story manager whose story named after the ID holds the work.";
      };

      projectSkill = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Skill to offer when a project has no PROJECT.md yet.";
      };
    };

    reviewLoop = {
      enable = mkEnableOption "the review-loop skill: review, verify, triage and fix until a round is clean";

      description = mkOption {
        type = types.str;
        default = ''Run a verified review loop on a target until a round comes back clean or a round cap is hit — each round a fresh reviewer finds non-nit issues, a fresh no-context verifier per finding tries to refute it, refuted findings and nits are dropped, and the survivors are fixed (or, for someone else's PR, drafted as review comments for approval). Use when the user says "review loop", "/review-loop <target>", or asks to review and fix something repeatedly until no findings remain.'';
        description = "The skill's frontmatter description (one line).";
      };

      argumentHint = mkOption {
        type = types.str;
        default = "<PR URL | doc path> [--max N] [--model opus]";
        description = "The skill's argument hint.";
      };

      targetKinds = mkOption {
        type = lines;
        default = ''
          - `pr` — a PR URL. `own` if the user authored it (check with
            `gh pr view <url> --json author`).
          - `doc` — any other file (Markdown, design doc, runbook, issue text).
        '';
        description = "Markdown list of the target kinds the loop recognizes (indented by the template).";
      };

      reviewedKinds = mkOption {
        type = types.str;
        default = "`doc`";
        description = "Kinds reviewed by the loop's own reviewer, as Markdown.";
      };

      prReviewSkill = mkOption {
        type = types.str;
        default = "/code-review";
        description = "Skill that reviews a PR in one round.";
      };

      prReview = mkOption {
        type = lines;
        default = ''
          - `pr` → run `${cfg.reviewLoop.prReviewSkill} <url>` for this round, without posting
            anything. For someone else's PR the loop ends with the verified findings drafted as
            review comments for the user to approve: re-run only after the author pushes. For an
            own PR, take its verified findings and go to 1c (fix as commits) instead of posting.
        '';
        defaultText = lib.literalMD "a step that runs `prReviewSkill`";
        description = "Markdown list item: how a round reviews a `pr` target.";
      };

      fixSteps = mkOption {
        type = lines;
        default = ''
          - `doc` → edit in place; keep a backup per round.
          - own `pr` → one fixup commit per finding on the commit that owns it, no push.
        '';
        description = "Markdown list: how each target kind is fixed.";
      };

      extraFinishSteps = mkOption {
        type = lines;
        default = "";
        description = "Markdown list items added to the loop's finish steps.";
      };

      reviewMethod = mkOption {
        type = lines;
        default = ''
          Gather the facts first, then cross-reference them against each other and the evidence.
          Return findings as text.
        '';
        description = "The reviewer's method paragraph.";
      };
    };
  };
}
