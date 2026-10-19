{
  config,
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
    #soxincfg.darwinModules.profiles.workstation.common
  ];

  soxin = {
    hardware = {
      # yubikey.enable = true;
    };

    programs = {
      less.enable = true;
    };
  };

  soxincfg = {
    programs = {
      dbeaver.enable = true;
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
