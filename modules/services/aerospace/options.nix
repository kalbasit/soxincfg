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
    # it, the home-manager side (zsh) picks the story variable from it.
    storyManager = mkOption {
      type = types.enum [
        "swm"
        "maktab"
      ];
      default = "maktab";
      description = ''
        The workspace manager whose stories the story switcher offers and
        opens. Both have the same `story list` and `workspace open` commands;
        they differ in the binary and in the variable that names the story:
        `SWM_STORY` for swm, `MAKTAB_STORY` for maktab. Set it in both the
        nix-darwin and the home-manager configuration of a host.
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
