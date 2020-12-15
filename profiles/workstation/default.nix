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
      brave.enable = true;
      git.enable = true;
    };

    services = {
      xserver.windowManager.i3.enable = true;
    };
  };
}
