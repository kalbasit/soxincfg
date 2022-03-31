# home-manager configuration for user `yl`
{ soxincfg }:
{ config, pkgs, home-manager, lib, ... }:

with lib;

{
  imports = [
    soxincfg.nixosModules.profiles.myself
    # soxincfg.nixosModules.profiles.work.keeptruckin
    soxincfg.nixosModules.profiles.workstation.darwin.local
  ];

  soxincfg.programs.neovim.enable = true;

  # TODO: Make gpg work, and re-enable this.
  soxincfg.programs.git.enableGpgSigningKey = false;
}
