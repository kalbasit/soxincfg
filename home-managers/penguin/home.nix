{ config, pkgs, home-manager, lib, soxincfg, ... }:

with lib;

{
  imports = [
    # TODO: requires sops support
    # soxincfg.nixosModules.profiles.myself

    # soxincfg.nixosModules.profiles.work.keeptruckin

    soxincfg.nixosModules.profiles.workstation.chromeos.local
  ];

  home.stateVersion = "22.11";
}
