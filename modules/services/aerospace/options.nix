{ lib, ... }:

let
  inherit (lib)
    mkEnableOption
    mkOption
    types
    ;
in
{
  options.soxincfg.services.aerospace = {
    enable = mkEnableOption "Install and configure Aerospace";

    # Declared in every mode: the darwin side lists and opens stories with
    # the manager, the home-manager side (zsh) reads the story variable.
    storyManager = mkOption {
      type = types.str;
      default = "swm";
      example = "my-story-manager";
      description = ''
        The binary of the workspace manager whose stories the story switcher
        offers and opens. It must have swm's `story list` and
        `workspace open` commands. Set it in both the nix-darwin and the
        home-manager configuration of a host.
      '';
    };

    storyList = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "my-story-manager-recent";
      description = ''
        The command that lists the stories the switcher offers, one per line,
        most recently active first. A line can follow the story with a tab and
        the Unix time of its last activity, which the switcher shows as an
        age. Null lists them with `storyManager story list`, without times.
        A command whose binary is `maktab` is read from stdout alone; any
        other is read from stdout and stderr, and lines with spaces are
        skipped as its errors, as swm prints them.
      '';
    };

    storyUrl = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "my-story-url";
      description = ''
        The command, run with a story's name, that prints the URL the browser
        of a new story workspace opens, such as the story's ticket. Printing
        nothing opens an empty window. Null always opens an empty window.
      '';
    };

    storyEnv = mkOption {
      type = types.str;
      default = "SWM_STORY";
      example = "MY_STORY";
      description = ''
        The environment variable that names the current story for the
        workspace manager of `storyManager`. Set it in both the nix-darwin
        and the home-manager configuration of a host.
      '';
    };

    storyProfile = mkOption {
      type = types.str;
      default = "personal";
      description = ''
        The zsh profile stories are listed under: story `foo` is offered as
        the workspace `<storyProfile>@foo`, the name a shell opened on it
        reads ZSH_PROFILE and the story from.
      '';
    };
  };
}
