# home-manager configuration for user `yl`
{ soxincfg }:
{ config, pkgs, home-manager, lib, ... }:

with lib;

{
  imports = [
    soxincfg.nixosModules.profiles.myself
    soxincfg.nixosModules.profiles.work.ulta
    soxincfg.nixosModules.profiles.workstation.nixos.local
  ];

  # Set the timezone temporarily to Europe.
  soxin.services.xserver.windowManager.bar.modules.time.timezones = singleton {
    timezone = "Europe/Kiev";
    prefix = "EEST";
    format = "%H:%M:%S";
  };

  # Setup the name of the wireless interface in Polybar
  soxin.services.xserver.windowManager.bar.modules.network.wlan = singleton "wlp82s0";

  # HiDPI
  soxin.programs.rofi.dpi = 196;
  xsession.pointerCursor = {
    package = pkgs.vanilla-dmz;
    name = "Vanilla-DMZ";
    size = 128;
  };
  soxin.services.xserver.windowManager.bar = {
    dpi = 196;
    height = 43;
  };
  services.dunst.settings.global.geometry = "600x100-15+58";
}
