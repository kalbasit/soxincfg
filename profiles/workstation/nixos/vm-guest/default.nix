{
  lib,
  mode,
  soxincfg,
  ...
}:

let
  inherit (lib) optionals;
in
{
  imports =
    [
      soxincfg.nixosModules.profiles.neovim
      # soxincfg.nixosModules.profiles.workstation.common
    ]
    ++ optionals (mode == "NixOS") [ ./nixos.nix ]
    ++ optionals (mode == "home-manager") [ ./home.nix ];

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
