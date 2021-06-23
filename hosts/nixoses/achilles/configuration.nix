{ config, lib, soxincfg, ... }:
let
  inherit (lib) mkForce;

  sopsFile = ./secrets.sops.yaml;
in
{
  imports = [
    soxincfg.nixosModules.profiles.myself
    soxincfg.nixosModules.profiles.work.ulta
    soxincfg.nixosModules.profiles.workstation.nixos.local

    ./hardware-configuration.nix
  ];

  # Set the timezone temporarily to Europe.
  location.latitude = mkForce 50.44;
  location.longitude = mkForce 30.58;
  time.timeZone = mkForce "Europe/Kiev";

  sops.secrets._etc_NetworkManager_system-connections_Nasreddine-VPN_nmconnection = { inherit sopsFile; path = "/etc/NetworkManager/system-connections/Nasreddine-VPN.nmconnection"; };

  # load YL's home-manager configuration
  home-manager.users.yl = import ./home.nix { inherit soxincfg; };

  soxin.hardware.intelBacklight.enable = true;

  # speed up the trackpad
  services.xserver.libinput.enable = true;
  services.xserver.libinput.touchpad.accelSpeed = "0.5";

  # enable fingerprint reader
  services.fprintd.enable = true;
  security.pam.services.login.fprintAuth = true;
  security.pam.services.xscreensaver.fprintAuth = true;
  security.pam.services.sudo.fprintAuth = true;

  system.stateVersion = "20.09";
}
