{ config, pkgs, home-manager, lib, soxincfg, ... }:

with lib;

{
  imports = [
    soxincfg.nixosModules.profiles.workstation.qubes.local
  ];
}
