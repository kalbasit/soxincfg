{
  home-manager,
  lib,
  soxincfg,
  ...
}:

let
  inherit (lib) optionals;
in
{
  imports = [
    soxincfg.darwinModules.profiles.neovim.full
    soxincfg.darwinModules.profiles.workstation.common
  ]

  ;

  soxin = {
    hardware = {
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
