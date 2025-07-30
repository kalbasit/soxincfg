{
  soxincfg,
  lib,
  mode,
  ...
}:

let
  inherit (lib)
    optionals
    ;
in
{
  imports = [
    soxincfg.nixosModules.profiles.neovim
  ]
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
    };

    soxincfg = {
      programs = {
        git.enable = true;
        ssh.enable = true;
        zsh.enable = true;
      };

      settings = {
        nix.distributed-builds.enable = true;
      };
    };
  };
}
