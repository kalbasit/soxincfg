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
  imports = [
    soxincfg.nixosModules.profiles.neovim.full
  ]
  ++ optionals (mode == "home-manager") [ ./home.nix ];

  config = {
    soxin = {
      programs = {
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
