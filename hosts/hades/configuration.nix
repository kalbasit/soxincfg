{ config, soxincfg, nixos-hardware, ... }:
let
  sopsFile = ./secrets.sops.yaml;
in
{
  imports = [
    soxincfg.nixosModules.profiles.myself
    soxincfg.nixosModules.profiles.work.keeptruckin
    soxincfg.nixosModules.profiles.workstation

    nixos-hardware.nixosModules.common-cpu-intel
    nixos-hardware.nixosModules.common-pc-laptop
    nixos-hardware.nixosModules.common-pc-ssd

    ./hardware-configuration.nix
  ];

  sops.secrets._etc_NetworkManager_system-connections_Nasreddine-VPN_nmconnection = { inherit sopsFile; path = "/etc/NetworkManager/system-connections/Nasreddine-VPN.nmconnection"; };

  # load YL's home-manager configuration
  home-manager.users.yl = import ./home.nix { inherit soxincfg; };

  soxin.hardware.intelBacklight.enable = true;

  system.stateVersion = "20.09";
}
