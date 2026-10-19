{
  config,
  pkgs,
  lib,
  ...
}:

with lib;
let
  cfg = config.soxincfg.settings.networking.nextdns;
in
{
  options = {
    soxincfg.settings.networking.nextdns = {
      enable = mkEnableOption ''
        Whether to enable nextdns.
      '';
    };
  };

  config = mkIf cfg.enable (mkMerge [
    ({ })
  ]);
}
