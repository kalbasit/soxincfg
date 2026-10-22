{
  soxincfg,
  lib,
  ...
}:

{
  imports = [
    soxincfg.darwinModules.profiles.neovim.full
  ]

  ;

  config = {
    soxin = {
      hardware = {
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
        ssh.enable = true;
        starship.enable = true;
        tmux.enable = true;
        zsh.enable = true;
      };

      settings = {
        nix.distributed-builds.enable = true;
      };
    };
  };
}
