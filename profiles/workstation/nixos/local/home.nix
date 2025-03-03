{
  services = {
    clipmenu.enable = true;
    flameshot.enable = true;
    betterlockscreen = {
      enable = true;
      inactiveInterval = 5;
      arguments = [ "--show-layout" ];
    };

    screen-locker = {
      enable = true;
      xss-lock = {
        screensaverCycle = 300;
      };
      xautolock = {
        enable = false;
      };
    };
  };
}
