{ config, lib, pkgs, ... }:

let
  inherit (lib)
    mkIf
    singleton
    ;

  cfg = config.soxincfg.programs.rofi;
in
{
  config = mkIf cfg.enable {
    programs.rofi.plugins = singleton pkgs.rofi-emoji;
  };
}
