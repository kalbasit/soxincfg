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
    soxincfg.homeModules.profiles.neovim.mini
  ];

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
