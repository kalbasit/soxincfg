{ mode, config, pkgs, lib, ... }:

with lib;
let
  cfg = config.soxin.programs.fzf;
in
{
  options = {
    soxin.programs.fzf = {
      enable = mkEnableOption "Whether to enable fzf, a command-line fuzzy finder.";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (optionalAttrs (mode == "home-manager") {
      programs.fzf = {
        enable = true;
        defaultCommand = ''(${pkgs.git}/bin/git ls-tree -r --name-only HEAD || ${pkgs.silver-searcher}/bin/ag --hidden --ignore .git -g "")'';
      };
    })
  ]);
}
