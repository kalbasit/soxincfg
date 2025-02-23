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
    # TODO: Enable once I have added a way to configure neovim from soxin
    # soxincfg.nixosModules.profiles.neovim
  ] ++ optionals (mode == "home-manager") [ ./home.nix ];

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
