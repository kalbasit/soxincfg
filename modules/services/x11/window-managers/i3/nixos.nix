{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.soxincfg.services.xserver.windowManager.i3;
in
{
  options.soxincfg.services.xserver.windowManager.i3 = {
    enable = mkEnableOption "programs.i3";
  };

  config = mkIf cfg.enable (mkMerge [
    { soxin.services.xserver.windowManager.i3.enable = true; }

    { }
  ]);
}
