{ mode, config, pkgs, lib, ... }:

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
      environment.variables.BROWSER = "${pkgs.nur.repos.kalbasit.rbrowser}/bin/rbrowser";

      services.xserver = {
        enable = true;
        autorun = true;
        autoRepeatDelay = 200;
        autoRepeatInterval = 30;

        xkbOptions = concatStringsSep "," [
          "ctrl:nocaps"
        ];

        libinput.enable = true;
        libinput.naturalScrolling = true;

        displayManager = {
          defaultSession = "none+i3";
          lightdm.enable = true;
          autoLogin = {
            enable = true;
            user = "yl";
          };
        };

        # videoDrivers = [
        #   "radeon"
        #   "cirrus"
        #   "vesa"
        #   "vmware"
        #   "modesetting"
        #   "intel"
        # ];

        windowManager = {
          i3.enable = true;
        };
      };
    })
  ]);
}
