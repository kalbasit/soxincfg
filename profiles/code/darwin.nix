{
  lib,
  soxincfg,
  ...
}:

let
  inherit (lib) optionals;
in
{
  imports = [
    soxincfg.darwinModules.profiles.myself
    soxincfg.darwinModules.profiles.neovim.full
  ]

  ;

  config = {
    soxin = {
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
        claude-code.enable = true;
        codex.enable = true;
        fzf.enable = true;
        git.enable = true;
        pet.enable = true;
        ssh.enable = true;
        starship.enable = true;
        maktab.enable = true;
        tmux.enable = true;
        zsh.enable = true;
      };

      settings = {
        nix.distributed-builds.enable = true;
        networking.nextdns.enable = true;
      };
    };
  };
}
