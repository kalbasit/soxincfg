{
  mode,
  config,
  pkgs,
  lib,
  ...
}:

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
      # TODO: Possibly replace pulseaudio with pipewire but for now, in order to build on 24.11 and not sure why it's enabled in the first place.
      services.pipewire.enable = false;

      services = {
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

    (optionalAttrs (mode == "NixOS") (
      mkIf cfg.focusRiteGen3Support {
        boot.extraModprobeConfig = "options snd_usb_audio vid=0x1235 pid=0x8210 device_setup=1";
      }
    ))
  ]);
}
