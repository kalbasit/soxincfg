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
    soxincfg.nixosModules.profiles.work.ulta
    soxincfg.nixosModules.profiles.workstation.nixos.local
  ];

  soxin.hardware.intelBacklight.enable = true;

  # XXX: Temporally disable remote build until SSH is fully configured.
  soxincfg.settings.nix.distributed-builds.enable = mkForce false;

  # XXX: Temporally disable GnuPG signing until it's fully configured.
  soxincfg.programs.git.enableGpgSigningKey = mkForce false;
  soxin.programs.git.gpgSigningKey = mkForce null;

  # Setup the name of the wireless interface in Polybar
  soxin.services.xserver.windowManager.bar.modules.network.wlan = singleton "wlp82s0";
}
