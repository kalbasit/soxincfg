{
  config,
  home-manager,
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
    #soxincfg.nixosModules.profiles.workstation.common
  ]
  ++ optionals (mode == "home-manager") [ ./home.nix ];

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
      mosh.enable = true;
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
