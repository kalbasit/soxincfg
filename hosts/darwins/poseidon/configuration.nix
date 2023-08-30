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

  soxincfg.programs.neovim.enable = true;

  # TODO: Make gpg work, and re-enable this.
  soxincfg.programs.git.enableGpgSigningKey = false;

  nix = {
    # package = inputs.nixpkgs-unstable.nixVersions.stable;
    # package = inputs.nixpkgs-unstable.nixStable;
    useDaemon = true;
  };
}
