{ config, lib, soxincfg, pkgs, ... }:
let
  inherit (lib)
    mkForce
    ;

  sopsFile = ./secrets.sops.yaml;
in
{
  imports = [
    soxincfg.nixosModules.profiles.myself
    soxincfg.nixosModules.profiles.work.ulta
    soxincfg.nixosModules.profiles.workstation.nixos.local

    ./hardware-configuration.nix
  ];

  sops.secrets._etc_NetworkManager_system-connections_Nasreddine-VPN_nmconnection = { inherit sopsFile; path = "/etc/NetworkManager/system-connections/Nasreddine-VPN.nmconnection"; };

  # load YL's home-manager configuration
  home-manager.users.yl = import ./home.nix { inherit soxincfg; };

  soxin.hardware.intelBacklight.enable = true;

  # speed up the trackpad
  services.xserver.libinput.enable = true;
  services.xserver.libinput.touchpad.accelSpeed = "0.5";

  # enable fingerprint reader
  # services.fprintd.enable = true;
  # security.pam.services.login.fprintAuth = true;
  # security.pam.services.xscreensaver.fprintAuth = true;
  # security.pam.services.sudo.fprintAuth = true;

  # store u2f for onlykey
  security.pam.u2f.authFile = pkgs.writeText "u2f-mappings" ''
    yl:KCQByPiHmtoaiz1uEbLam0MfKQFM42j0oKs5tu5aiW90Zw5eJFrDYiPc2DzEg+BVHIRQdwr9ZPrlfVc9OifrYVKjA1flAA==,/Xd63dtwo3k7W/ob8ZgaSdQF64ycxk3whm9xMjLXCLP+AO/ZlnlxqM4vBPbetPRqaT7jCm7L4+sk6Xs3fNktaA==,es256,+presence
  '';

  # XXX: Temporally disable remote build until SSH is fully configured.
  soxincfg.settings.nix.distributed-builds.enable = mkForce false;

  # XXX: Temporally disable GnuPG signing until it's fully configured.
  soxincfg.programs.git.enableGpgSigningKey = mkForce false;
  soxin.programs.git.gpgSigningKey = mkForce null;

  system.stateVersion = "20.09";
}
