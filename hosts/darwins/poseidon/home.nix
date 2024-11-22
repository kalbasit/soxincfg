# home-manager configuration for user `yl`
{ soxincfg }:
{
  config,
  pkgs,
  home-manager,
  lib,
  ...
}:

with lib;

{
  imports = [
    soxincfg.nixosModules.profiles.myself
    soxincfg.nixosModules.profiles.workstation.darwin.local
  ];

  home.stateVersion = "23.05";
}
