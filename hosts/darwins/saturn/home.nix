# home-manager configuration for user `yl`
{ soxincfg }:
{ config, pkgs, home-manager, lib, ... }:

with lib;

{
  imports = [
    soxincfg.nixosModules.profiles.myself
    soxincfg.nixosModules.profiles.workstation.darwin.local
  ]
  ++ (soxincfg.nixosModules.profiles.work.imports { hostName = "saturn"; });

  home.stateVersion = "23.05";
}
