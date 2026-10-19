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
    ({ })

    ({
      gtk = {
        enable = true;
        font = {
          name = "0xProto Nerd Font:style=Regular:size=12:antialias=true";
        };
        iconTheme = {
          package = pkgs.arc-icon-theme;
          name = "Arc";
        };
        theme = {
          package = pkgs.arc-theme;
          name = "Arc-dark";
        };
      };
    })
  ]);
}
