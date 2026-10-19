{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.soxincfg.services.nextcloud;
in
{
  options.soxincfg.services.nextcloud.enable = mkEnableOption "Install and configure nextcloud";

  config = mkIf cfg.enable (mkMerge [
    { }
  ]);
}
