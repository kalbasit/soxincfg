{ config, soxincfg, lib, pkgs, ... }:
with lib;
{
  imports = [
    soxincfg.nixosModules.profiles.server

    ./hardware-configuration.nix
  ];

  networking.useDHCP = false;
  networking.interfaces.ens3.useDHCP = true;

  system.stateVersion = "20.09";
}
