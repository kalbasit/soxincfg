{
  config,
  lib,
  ...
}:

with lib;

{
  options = {
    soxin.hardware.bluetooth.enable = mkEnableOption "Enable bluetooth";
  };

  config = mkIf config.soxin.hardware.bluetooth.enable (mkMerge [

    ({ })

    ({ })

  ]);
}
