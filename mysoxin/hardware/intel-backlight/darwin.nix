{
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
    ({ })
  ]);
}
