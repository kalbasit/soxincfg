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
    soxincfg.homeModules.profiles.neovim.full
  ]
 
  ++ [ ./home-config.nix ];

  config = {
    soxin = {
      programs = {
        keybase.enable = true;
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
        maktab.enable = true;
        termite.enable = true;
        tmux.enable = true;
        zsh.enable = true;
      };

      settings = {
        fonts.enable = true;
        gtk.enable = true;
      };
    };
  };
}
