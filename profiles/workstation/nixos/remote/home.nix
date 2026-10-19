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
    soxincfg.homeModules.profiles.neovim.full
    soxincfg.homeModules.profiles.workstation.common
  ]
 
  ++ [ ./home-config.nix ];

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
