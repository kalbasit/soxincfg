{ mode, config, pkgs, lib, master, ... }:

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
    (optionalAttrs (mode == "home-manager") {
      xsession = {
        enable = true;

        windowManager = {
          i3 = import ./i3-config.lib.nix { inherit config pkgs lib master; };
        };

        initExtra = ''
          exec &> ~/.xsession-errors

          # fix the look of Java applications
          export _JAVA_OPTIONS='-Dawt.useSystemAAFontSettings=on -Dswing.aatext=true -Dswing.defaultlaf=com.sun.java.swing.plaf.gtk.GTKLookAndFeel'
        '';

        scriptPath = ".hm-xsession";
      };
    })
  ]);
}
