{ ... }:

{
  soxin = {
    hardware = {
      bluetooth.enable = true;
    };

    programs = {
      neovim.enable = true;
    };
  };

  soxincfg = {
    programs = {
      git.enable = true;
    };

    services = {
      xserver.windowManager.i3.enable = true;
    };
  };
}
