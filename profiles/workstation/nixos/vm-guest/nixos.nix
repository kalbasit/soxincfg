{
  environment.homeBinInPath = true;

  services = {
    qemuGuest.enable = true;

    # Feed the kernel some entropy
    haveged.enable = true;

    desktopManager.gnome.enable = true;

    displayManager.gdm.enable = true;

    xserver.enable = true;
  };

  # Enable dconf required by most guis
  programs.dconf.enable = true;
}
