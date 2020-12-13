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

        # TODO: move this to keyboard
        xkbOptions = concatStringsSep "," [
          "grp:alt_caps_toggle"
          "caps:swapescape"
        ];

        libinput = {
          enable = true;
        };

        displayManager = {
          defaultSession = "none+i3";
          lightdm = {
            enable = true;
            autoLogin = {
              enable = true;
              user = "risson";
            };
          };
        };

        videoDrivers = [
          "radeon"
          "cirrus"
          "vesa"
          "vmware"
          "modesetting"
          "intel"
        ];

        windowManager = {
          i3.enable = true;
        };
      };
    })
  ]);
}
