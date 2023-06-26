{ config, lib, ... }:

let
  inherit (lib)
    mkEnableOption
    ;

  cfg = config.soxin.hardware.rtl-sdr;
in
{
  options.soxin.hardware.rtl-sdr = {
    enable = mkEnableOption "hardware.rtl-sdr";
  };
}
