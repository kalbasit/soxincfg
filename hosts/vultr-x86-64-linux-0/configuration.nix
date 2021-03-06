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

  # enable tripin.tech
  soxincfg.services.wordpress.tripintech = {
    enable = true;
    openFirewall = true;
  };
  services.wordpress.tripintech = {
    virtualHost = {
      hostName = "tripin.tech";

      enableACME = true;
      forceSSL = true;
    };
  };

  system.stateVersion = "20.09";
}
