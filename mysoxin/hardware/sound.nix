{ mode, config, pkgs, lib, ... }:

with lib;
let
  cfg = config.soxin.hardware.sound;
in
{
  options = {
    soxin.hardware.sound = {
      enable = mkEnableOption "sound";

      # TODO
      # https://github.com/Focusrite-Scarlett-on-Linux/sound-usb-kernel-module
      focusRiteGen3Support = mkEnableOption "support for Focusrite Scarlet Gen3";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (optionalAttrs (mode == "NixOS") {
      sound.enable = true;

      hardware = {
        pulseaudio = {
          enable = true;
          package = mkIf config.soxin.hardware.bluetooth.enable pkgs.pulseaudioFull;
        };
      };

      environment.systemPackages = with pkgs; [
        pavucontrol
        pa_applet
      ];
    })

    (optionalAttrs (mode == "NixOS") (mkIf cfg.focusRiteGen3Support {
      # Fix for Scarlet Focusrite
      boot.extraModprobeConfig = "options snd_usb_audio vid=0x1235 pid=0x8210 device_setup=1";
      boot.kernelPackages = pkgs.linuxPackages_5_11;
      boot.kernelPatches =
        let
          focusrite-scarlett-backports = pkgs.fetchFromGitHub {
            owner = "sadko4u";
            repo = "focusrite-scarlett-backports";
            rev = "97ab71438152ab4665005419fa131cf6d9958495";
            sha256 = "sha256-WfOrVXUa9khLc1+Wc1aoC568nbZ1tBo3ODhzneb4lTc=";
          };

        in
        singleton {
          name = "focusrite-scarlett-backports";
          patch = "${focusrite-scarlett-backports}/vanilla-linux-5.11.1-scarlett-gen3.patch";
        };
    }))
  ]);
}
