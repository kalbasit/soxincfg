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
  };
}
