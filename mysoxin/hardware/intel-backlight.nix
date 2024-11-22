{
  mode,
  config,
  pkgs,
  lib,
  ...
}:

with lib;
let
  cfg = config.soxin.hardware.intelBacklight;
in
{
  options = {
    soxin.hardware.intelBacklight = {
      enable = mkEnableOption "Enable Intel backlight by a group of users.";
      group = mkOption {
        type = types.str;
        default = "video";
        description = ''
          Group of users allowed to adjust the backlight.
        '';
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (optionalAttrs (mode == "NixOS") {
      # Give people part of the ${cfg.group} group access to adjust the backlight
      services.udev.extraRules = ''
        ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="intel_backlight", RUN+="${pkgs.coreutils}/bin/chgrp ${cfg.group} /sys/class/backlight/%k/brightness"
        ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="intel_backlight", RUN+="${pkgs.coreutils}/bin/chmod g+w /sys/class/backlight/%k/brightness"
      '';
    })
  ]);
}
