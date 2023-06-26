{ config, lib, mode, pkgs, ... }:

let
  inherit (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.soxin.hardware.rtl-sdr;
in
{
  options.soxin.hardware.rtl-sdr = {
    enable = mkEnableOption "hardware.rtl-sdr";
  };

  config = mkIf cfg.enable {
    hardware.rtl-sdr.enable = true;
    soxincfg.settings.users.defaultGroups = [ "plugdev" ];
    environment.systemPackages = [
      pkgs.rtl-sdr
      pkgs.rtl_433
    ];
  };
}
