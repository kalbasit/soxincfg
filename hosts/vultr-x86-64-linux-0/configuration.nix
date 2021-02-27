{ config, soxincfg, lib, pkgs, ... }:
with lib;
{
  imports = [
    soxincfg.nixosModules.profiles.server

    ./hardware-configuration.nix
  ];

  networking.useDHCP = false;
  networking.interfaces.ens3.useDHCP = true;

  soxincfg.services.wordpress.tripintech.enable = true;
  services.wordpress.tripintech = {
    virtualHost = {
      adminAddr = "wael.nasreddine@gmail.com";
      hostName = "tripin.tech";
    };
  };

  system.stateVersion = "20.09";
}
