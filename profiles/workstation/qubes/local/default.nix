{ lib, mode, soxincfg, ... }:

let
  inherit (lib)
    optionals
    ;
in
{
  imports =
    [
      soxincfg.nixosModules.profiles.neovim
    ]
    ++ optionals (mode == "home-manager") [ ./home.nix ];

  config = {
    soxin = {
      programs = {
        git = {
          signing = {
            key = "wael.nasreddine@gmail.com";
            signByDefault = true;
          };
        };
        less.enable = true;
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
    };
  };
}
