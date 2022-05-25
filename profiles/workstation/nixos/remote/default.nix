{ config, home-manager, lib, mode, pkgs, soxincfg, ... }:

let
  inherit (lib)
    mkForce
    optionals
    ;

  inherit (home-manager.lib.hm.dag)
    entryBefore
    entryAnywhere
    ;
in
{
  imports =
    [
      soxincfg.nixosModules.profiles.neovim
      soxincfg.nixosModules.profiles.workstation.common
    ]
    ++ optionals (mode == "NixOS") [ ./nixos.nix ]
    ++ optionals (mode == "home-manager") [ ./home.nix ];

  soxin = {
    hardware = { fwupd.enable = true; };

    programs = {
      keybase = {
        enable = true;
        enableFs = true;
      };
      less.enable = true;
    };

    services = { openssh.enable = true; };
    virtualisation = { docker.enable = true; };
  };

  soxincfg = {
    programs = {
      fzf.enable = true;
      git = {
        enable = true;

        # No need to attempt to sign commits via GnuPG as it really does not
        # work well, yet.
        enableGpgSigningKey = mkForce false;
      };
      mosh.enable = true;
      pet.enable = true;
      ssh = {
        enable = true;

        # XXX: Remote machines do not have any keys (or shouldn't) and must use my SSH agent instead.
        identitiesOnly = mkForce false;
      };
      starship.enable = true;
      tmux.enable = true;
      zsh.enable = true;
    };

    settings = {
      nix.distributed-builds.enable = true;
    };
  };
}
