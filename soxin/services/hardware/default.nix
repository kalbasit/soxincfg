{ mode, config, lib, ... }:

with lib;

{
  options = {
    soxin.hardware = {
      enable = mkEnableOption "Enable default hardware settings";
    };
  };

  config = mkIf config.soxin.hardware.enable (mkMerge [
    (optionalAttrs (mode == "NixOS") {
      services.fwupd.enable = true;
    })
  ]);
}
