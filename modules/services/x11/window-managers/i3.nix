{ config, lib, mode, pkgs, ... }:

with lib;

with lib;
let
  cfg = config.soxincfg.services.xserver.windowManager.i3;

  defaultModifier = "Mod4";
  secondModifier = "Shift";
  thirdModifier = "Mod1";
  nosid = "--no-startup-id";
in
{
  options.soxincfg.services.xserver.windowManager.i3 = {
    enable = mkEnableOption "programs.i3";
  };

  config = mkIf cfg.enable (mkMerge [
    { soxincfg.services.xserver.windowManager.i3.enable = true; }

    (optionalAttrs (mode == "home-manager") {
      xsession.windowManager.i3.config = {
        keybindings = {
          "${defaultModifier}+${thirdModifier}+s" = "exec ${nosid} ${getBin pkgs.pulseaudio}/bin/pactl set-source-mute @DEFAULT_SOURCE@ toggle";
        };


        startup = [
          { command = "${getBin pkgs.nitrogen}/bin/nitrogen --restore"; always = false; notification = false; }
        ];
      };
    })
  ]);
}
