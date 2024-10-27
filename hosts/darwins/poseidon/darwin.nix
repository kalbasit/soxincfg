{ config, lib, pkgs, inputs, soxincfg, ... }:

let
  inherit (lib)
    singleton
    ;
in
{
  imports = [
    soxincfg.nixosModules.profiles.myself
    soxincfg.nixosModules.profiles.workstation.darwin.local
  ];

  # load YL's home-manager configuration
  home-manager.users.yl = import ./home.nix { inherit soxincfg; };

  system.stateVersion = 5;
}
