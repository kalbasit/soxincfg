{ config, lib, soxincfg, pkgs, ... }:
let
  inherit (lib)
    mkForce
    singleton
    ;
in
{
  imports = [
    soxincfg.nixosModules.profiles.myself
    soxincfg.nixosModules.profiles.work.arklight
    soxincfg.nixosModules.profiles.work.ulta
    soxincfg.nixosModules.profiles.workstation.nixos.local
  ];

  soxin.hardware.intelBacklight.enable = true;

  # Setup the name of the wireless interface in Polybar
  soxin.services.xserver.windowManager.bar.modules.network.wlan = singleton "wlp82s0";
}
