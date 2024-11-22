{ config, lib, ... }:

let
  inherit (lib) mkEnableOption;

  cfg = config.soxin.hardware.zsa;
in
{
  options.soxin.hardware.zsa = {
    enable = mkEnableOption "hardware.zsa";
  };
}
