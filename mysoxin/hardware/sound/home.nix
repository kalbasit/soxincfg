{
  config,
  pkgs,
  lib,
  ...
}:

with lib;
let
  cfg = config.soxin.hardware.sound;
in
{
  options = {
    soxin.hardware.sound = {
      enable = mkEnableOption "sound";

      # TODO
      # https://github.com/Focusrite-Scarlett-on-Linux/sound-usb-kernel-module
      focusRiteGen3Support = mkEnableOption "support for Focusrite Scarlet Gen3";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    { }

    { }
  ]);
}
