# home-manager configuration for user `yl`
{ soxincfg }:
{ config, pkgs, home-manager, lib, ... }:

with lib;

{
  imports = [ ./soxincfg.nix ];

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

  # use Termite on this laptop not sure why WezTerm is not working well (window size is limited).
  # TODO: fix this
  xsession.windowManager.i3.config.keybindings = {
    "Mod4+Return" = mkForce "exec ${getBin pkgs.termite}/bin/termite";
    "Mod4+Shift+Return" = mkForce "exec ${getBin pkgs.wezterm}/bin/wezterm";
  };
}
