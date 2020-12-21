# home-manager configuration for user `yl`
{ soxincfg }:
{ config, pkgs, home-manager, lib, ... }:

with lib;

{
  imports = [ soxincfg.nixosModules.profiles.remote-workstation ];
}
