{
  config,
  pkgs,
  lib,
  ...
}:

with lib;
let
  cfg = config.soxin.services.xserver;
in
{
  options = {
    soxin.services.xserver = {
      enable = mkEnableOption "Whether to enable Xorg.";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    ({ })
  ]);
}
