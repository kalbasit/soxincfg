{
  config,
  pkgs,
  lib,
  ...
}:

with lib;
let
  cfg = config.soxincfg.settings.gtk;
in
{
  options = {
    soxincfg.settings.gtk = {
      enable = mkEnableOption "GTK";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    { }

    { }
  ]);
}
