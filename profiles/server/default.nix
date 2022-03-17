{ soxincfg, lib, mode, ... }:

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
    [ ]
    ++ optionals (mode == "NixOS") [ ./nixos.nix ]
    ++ optionals (mode == "home-manager") [ ./home.nix ];

  config = {
    soxin = {
      hardware = {
        fwupd.enable = true;
      };

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
        libvirtd.enable = true;
      };
    };

    soxincfg = {
      programs = {
        fzf.enable = true;
        git.enable = true;
        mosh.enable = true;
        neovim.enable = true;
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
  };
}
