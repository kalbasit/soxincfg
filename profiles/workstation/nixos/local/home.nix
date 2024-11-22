{ config, ... }:

{
  services.clipmenu.enable = true;
  services.flameshot.enable = true;
  services.betterlockscreen = {
    enable = true;
    inactiveInterval = 5;
    arguments = [ "--show-layout" ];
  };

  services.screen-locker = {
    enable = true;
    xss-lock = {
      screensaverCycle = 300;
    };
    xautolock = {
      enable = false;
    };
  };
}
