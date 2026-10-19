{
  config,
  pkgs,
  lib,
  master,
  ...
}:

with lib;
let
  cfg = config.soxin.services.xserver.windowManager.i3;
in
{
  options = {
    soxin.services.xserver.windowManager.i3 = {
      enable = mkEnableOption "i3";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    { }
  ]);
}
