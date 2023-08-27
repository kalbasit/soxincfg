{ config, lib, ... }:

let
  inherit (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.soxin.hardware.zsa;
in
{
  options.soxin.hardware.zsa = {
    enable = mkEnableOption "hardware.zsa";
  };

  config = mkIf cfg.enable {
    soxincfg.settings.users.defaultGroups = [ "plugdev" ];
  };
}
