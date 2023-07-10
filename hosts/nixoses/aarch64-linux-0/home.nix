# home-manager configuration for user `yl`
{ soxincfg }:
{ config, pkgs, home-manager, lib, ... }:

with lib;

{
  imports = [
    soxincfg.nixosModules.profiles.myself
    soxincfg.nixosModules.profiles.workstation.nixos.remote
  ]
  ++ (soxincfg.nixosModules.profiles.work.imports { hostName = "aarch64-linux-0"; });

  home.stateVersion = "23.05";
}
