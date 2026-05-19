{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.soxincfg.programs.swm;
in
{
  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.swm-full ];

    programs.zsh.shellAliases.s = "swm workspace open";

    programs.pet.snippets = lib.singleton {
      description = "swm-story-remove";
      command = "swm story remove";
    };

    soxin.programs.tmux.extraConfig = ''
      bind s split-window -p 20 -v ${pkgs.swm-full}/bin/swm workspace open --kill-pane
    '';
  };
}
