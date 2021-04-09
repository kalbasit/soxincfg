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
    ./win10.nix
  ];

  sops.secrets._etc_NetworkManager_system-connections_Nasreddine-VPN_nmconnection = { inherit sopsFile; path = "/etc/NetworkManager/system-connections/Nasreddine-VPN.nmconnection"; };

  # load YL's home-manager configuration
  home-manager.users.yl = import ./home.nix { inherit soxincfg; };

  soxin.hardware.intelBacklight.enable = true;

  # The ADMIN interface
  networking.interfaces.eno1.useDHCP = false; # Turn off DHCP on the main network as gets priority on DNS server
  networking.interfaces.ifcadmin.useDHCP = true; # Turn on DHCP on the admin interface
  networking.networkmanager.unmanaged = [ "eno1" "ifcadmin" ]; # Tell NM not to manage the wired connection
  networking.vlans.ifcadmin = { id = 2; interface = "eno1"; }; # Create the ifcadmin interface

  system.stateVersion = "20.09";
}
