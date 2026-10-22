{
  config,
  pkgs,
  lib,
  ...
}:

with lib;
let
  cfg = config.soxin.hardware.lowbatt;
in
{
  options.soxin.hardware.lowbatt = {
    enable = mkEnableOption "Whether to enable battery notifier.";

    devices = mkOption {
      type = with types; listOf str;
      default = [ "BAT0" ];
      description = ''
        Devices to monitor.
      '';
      apply = value: concatStringsSep " " value;
    };

    notifyCapacity = mkOption {
      type = types.int;
      default = 10;
      description = ''
        Battery level at which a notification shall be sent.
      '';
      apply = toString;
    };

    hibernateCapacity = mkOption {
      type = types.int;
      default = 5;
      description = ''
        Battery level at which a hibernate unless connected shall be sent.
      '';
      apply = toString;
    };
  };

  config = mkIf cfg.enable (mkMerge [
    { }
  ]);
}
