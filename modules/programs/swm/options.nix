{ lib, pkgs, ... }:

let
  inherit (lib) mkEnableOption mkOption types;

  toml = pkgs.formats.toml { };
in
{
  options.soxincfg.programs.swm = {
    enable = mkEnableOption "swm, the story and workspace manager";

    package = mkOption {
      type = types.package;
      description = "The swm package to install, with the plugins it should find.";
    };

    name = mkOption {
      type = types.str;
      default = "swm";
      example = "maktab";
      description = ''
        Name of the story manager: its executable, the directory under the
        config directory it reads, and the prefix of the variables its hooks
        get (`SWM_WORKTREE_PATH` for `swm`). Set it to `maktab` to manage
        maktab, swm's successor, with this module.
      '';
    };

    codeRoot = mkOption {
      type = types.str;
      default = "~/code";
      description = "Directory holding the repositories and story worktrees.";
    };

    defaultStory = mkOption {
      type = types.str;
      default = "_default";
      description = "Story used when none is selected; its checkout is the canonical clone.";
    };

    forges = mkOption {
      type = types.listOf types.str;
      default = [ "github" ];
      description = "Forge plugins swm loads.";
    };

    branchNameTemplate = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "user/alice/{{.Name}}";
      description = ''
        Go template for a story's branch name. Null means
        `user/<home.username>/{{.Name}}`.
      '';
    };

    settings = mkOption {
      inherit (toml) type;
      default = { };
      description = "Extra settings merged into swm's config.toml.";
    };

    sessionWindows = mkOption {
      type = types.listOf toml.type;
      default = [
        {
          name = "code";
          panes = [ { commands = [ "nvim" ]; } ];
        }
        {
          name = "claude";
          panes = [
            {
              focus = true;
              commands = [ "claude --dangerously-skip-permissions" ];
            }
          ];
        }
        {
          name = "shell";
          panes = [ { flex = 1; } ];
        }
      ];
      description = "Windows of the tmux session swm opens for a story.";
    };

    hooks = mkOption {
      type = types.attrsOf (types.attrsOf types.lines);
      default = { };
      example = lib.literalExpression ''
        {
          post-worktree-create."30-notify" = '''
            #!/bin/sh
            echo "created $SWM_WORKTREE_PATH"
          ''';
        }
      '';
      description = ''
        Global hooks, as event -> file name -> script. Each is written,
        executable, to `hooks/<event>.d/<name>` in the manager's config
        directory, and runs for every repository. Per-repository hooks live in
        the repository and are not managed here.
      '';
    };

    direnvHook.enable = mkEnableOption ''
      a post-worktree-create hook that allows a new worktree's .envrc when it
      is identical to the canonical clone's and the clone's is already
      allowed, then loads it so its dev shell is built right away
    '';

    gitSpiceTrackHook.enable = mkEnableOption ''
      a post-worktree-create hook that tracks the new branch in git-spice
      against the repository's trunk, in repositories where git-spice is
      initialized
    '';

    claudeRules = mkOption {
      type = types.nullOr types.path;
      default = null;
      example = lib.literalExpression ''"''${inputs.swm}/contrib/claude-rules"'';
      description = ''
        Directory of Claude Code rules shipped with the story manager (the
        story-confinement and story-from-path rules). Every `.md` file in it is
        linked into `~/.claude/rules`. Null installs none.
      '';
    };
  };
}
