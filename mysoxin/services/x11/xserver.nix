{
  mode,
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
    (optionalAttrs (mode == "NixOS") {
      services.libinput = {
        enable = true;
        mouse.naturalScrolling = true;
        touchpad.naturalScrolling = true;
      };

      services.displayManager = {
        autoLogin = {
          enable = true;
          user = "yl";
        };
      };

      services.xserver = {
        enable = true;
        autorun = true;
        autoRepeatDelay = 200;
        autoRepeatInterval = 30;

        xkb.options = concatStringsSep "," [ "ctrl:nocaps" ];

        displayManager = {
          lightdm.enable = true;
        };

        desktopManager.session = [
          {
            name = "home-manager";
            start = ''
              ${pkgs.runtimeShell} $HOME/.hm-xsession &
              waitPID=$!
            '';
          }
        ];
      };
    })
  ]);
}
