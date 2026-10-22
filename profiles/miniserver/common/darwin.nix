{
  lib,
  soxincfg,
  ...
}:

{
  imports = [
    soxincfg.darwinModules.profiles.neovim.mini
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
