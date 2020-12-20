{ mode, config, pkgs, lib, ... }:

with lib;
let
  cfg = config.soxin.programs.termite;
in
{
  options = {
    soxin.programs.termite = {
      enable = mkEnableOption "termite";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (optionalAttrs (mode == "home-manager") {
      programs.termite = {
        enable = true;
        font = "Source Code Pro for Powerline 9";
      };
    })
  ]);
}
