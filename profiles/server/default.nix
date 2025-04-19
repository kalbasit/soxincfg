{
  soxincfg,
  lib,
  mode,
  ...
}:

let
  inherit (lib)
    mkDefault
    mkEnableOption
    mkIf
    optionalAttrs
    optionals
    ;
in
{
  imports =
    [ soxincfg.nixosModules.profiles.neovim ]
    ++ optionals (mode == "NixOS") [ ./nixos.nix ]
    ++ optionals (mode == "home-manager") [ ./home.nix ];

  config = {
    soxin = {
      hardware = {
        fwupd.enable = true;
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
        mosh.enable = true;
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
