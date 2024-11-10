{ config, pkgs, home-manager, lib, soxincfg, ... }:

with lib;

{
  imports = [
    soxincfg.nixosModules.profiles.myself
    soxincfg.nixosModules.profiles.workstation.qubes.local
  ];
}
