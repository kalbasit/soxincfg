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
      services.xserver = {
        enable = true;
        autorun = true;
        autoRepeatDelay = 200;
        autoRepeatInterval = 30;

        xkb.options = concatStringsSep "," [ "ctrl:nocaps" ];

        libinput.enable = true;
        libinput.mouse.naturalScrolling = true;
        libinput.touchpad.naturalScrolling = true;

        displayManager = {
          lightdm.enable = true;
          autoLogin = {
            enable = true;
            user = "yl";
          };
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
