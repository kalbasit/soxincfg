{ ... }:

{
  soxin = {
    hardware = {
      bluetooth.enable = true;
    };

    programs = {
      fzf.enable = true;
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
