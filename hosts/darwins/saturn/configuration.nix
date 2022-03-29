{ config, lib, pkgs, inputs, soxincfg, ... }:

let
  inherit (lib)
    singleton
    ;
in
{
  imports = [
    soxincfg.nixosModules.profiles.myself
    # soxincfg.nixosModules.profiles.work.keeptruckin
    soxincfg.nixosModules.profiles.workstation.darwin.local
  ];

  # load YL's home-manager configuration
  home-manager.users.yl = import ./home.nix { inherit soxincfg; };

  environment.systemPath = singleton "/etc/profiles/per-user/yl/bin";

  nix = {
    # package = inputs.nixpkgs-unstable.nixVersions.stable;
    # package = inputs.nixpkgs-unstable.nixStable;
    useDaemon = true;
  };
}
