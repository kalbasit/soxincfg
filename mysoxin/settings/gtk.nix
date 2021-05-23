{ mode, config, pkgs, lib, ... }:

with lib;
let
  cfg = config.soxin.settings.gtk;
in
{
  options = {
    soxin.settings.gtk = {
      enable = mkEnableOption "GTK";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (optionalAttrs (mode == "NixOS") {
      services.dbus.packages = [ pkgs.gnome3.dconf ];
    })

    (optionalAttrs (mode == "home-manager") {
      gtk = {
        enable = true;
        font = {
          package = pkgs.hack-font;
          name = "xft:SourceCodePro:style:Regular:size=9:antialias=true";
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
