{ config, lib, mode, pkgs, ... }:

with lib;
let
  cfg = config.soxincfg.programs.fzf;
in
{
  options.soxincfg.programs.fzf = {
    enable = mkEnableOption "programs.fzf";
  };

  config = mkIf cfg.enable (mkMerge [
    (optionalAttrs (mode == "home-manager") {
      programs.fzf = {
        enable = true;

        # TODO: Why was git piped to ag?
        # programs.fzf.defaultCommand = ''(${pkgs.git}/bin/git ls-tree -r --name-only HEAD || ${pkgs.silver-searcher}/bin/ag --hidden --ignore .git -g "")'';
        defaultCommand = "${pkgs.git}/bin/git ls-tree -r --name-only HEAD";
      };
    })
  ]);
}
