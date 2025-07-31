{
  lib,
  mode,
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
  ++ optionals (mode == "NixOS") [ ./nixos.nix ];

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
