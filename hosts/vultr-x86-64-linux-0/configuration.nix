{ config, soxincfg, lib, pkgs, ... }:
with lib;
{
  imports = [
    soxincfg.nixosModules.profiles.server

    ./hardware-configuration.nix
  ];

  networking.useDHCP = false;
  networking.interfaces.ens3.useDHCP = true;

  security.acme = {
    email = "kalbasit@pm.me";
    acceptTerms = true;
  };

  soxincfg.services.wordpress.tripintech = {
    enable = true;
    openFirewall = true;
  };
  services.wordpress.tripintech = {
    virtualHost = {
      adminAddr = "wael.nasreddine@gmail.com";
      hostName = "tripin.tech";

      enableACME = true;
      forceSSL = true;
    };
  };

  system.stateVersion = "20.09";
}
