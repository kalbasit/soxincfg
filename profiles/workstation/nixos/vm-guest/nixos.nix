{
  environment.homeBinInPath = true;

  services = {
    qemuGuest.enable = true;

    # Feed the kernel some entropy
    haveged.enable = true;

    xserver = {
      enable = true;
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
    };
  };

  # Enable dconf required by most guis
  programs.dconf.enable = true;
}
