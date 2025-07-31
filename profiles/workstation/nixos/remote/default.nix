{
  home-manager,
  lib,
  mode,
  soxincfg,
  ...
}:

let
  inherit (lib) optionals;
in
{
  imports = [
    soxincfg.nixosModules.profiles.neovim.full
    soxincfg.nixosModules.profiles.workstation.common
  ]
  ++ optionals (mode == "NixOS") [ ./nixos.nix ]
  ++ optionals (mode == "home-manager") [ ./home.nix ];

  soxin = {
    hardware = {
      fwupd.enable = true;
    };

    programs = {
      keybase = {
        enable = true;
        enableFs = true;
      };
      less.enable = true;
    };

    services = {
      openssh.enable = true;
    };
    virtualisation = {
      docker.enable = true;
    };
  };

  soxincfg = {
    programs = {
      fzf.enable = true;
      git.enable = true;
      mosh.enable = true;
      pet.enable = true;
      ssh.enable = true;
      starship.enable = true;
      tmux.enable = true;
      zsh.enable = true;
    };

    settings = {
      nix.distributed-builds.enable = true;
    };
  };
}
