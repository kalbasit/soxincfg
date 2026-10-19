{
  lib,
  soxincfg,
  ...
}:

let
  inherit (lib)
    optionals
    ;
in
{
  imports = [
    soxincfg.nixosModules.profiles.neovim.mini
  ]
  ++ [ ./nixos-config.nix ];

  config = {
    soxin = {
      services = {
        openssh.enable = true;
      };
    };

    soxincfg = {
      programs = {
        ssh = {
          enable = true;
          enableSSHAgent = false;
        };
      };
    };
  };
}
