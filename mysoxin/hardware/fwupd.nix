{
  mode,
  config,
  pkgs,
  lib,
  ...
}:

with lib;
let
  cfg = config.soxin.hardware.fwupd;
in
{
  options = {
    soxin.hardware.fwupd = {
      enable = mkEnableOption "Firmware Update";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (optionalAttrs (mode == "NixOS") { services.fwupd.enable = true; })
  ]);
}
