{ mode, config, pkgs, lib, ... }:

with lib;
let
  cfg = config.soxincfg.programs.termite;
in
{
  options = {
    soxincfg.programs.termite = {
      enable = mkEnableOption "termite";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    { soxin.programs.termite.enable = true; }

    (optionalAttrs (mode == "home-manager") {
      programs.termite.font = "Source Code Pro for Powerline 9";
    })
  ]);
}
