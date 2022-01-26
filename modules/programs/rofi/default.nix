{ config, lib, mode, pkgs, ... }:

let
  inherit (lib)
    mkIf
    mkEnableOption
    optionals
    ;

  cfg = config.soxincfg.programs.rofi;
in
{
  imports =
    [ ]
    ++ optionals (mode == "home-manager") [ ./home.nix ];

  options.soxincfg.programs.rofi = {
    enable = mkEnableOption "programs.rofi";
  };

  config = mkIf cfg.enable {
    soxin.programs.rofi = {
      enable = true;
      i3.enable = true;
    };
  };
}
