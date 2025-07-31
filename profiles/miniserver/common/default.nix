{
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
  imports = optionals (mode == "NixOS") [ ./nixos.nix ];

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
