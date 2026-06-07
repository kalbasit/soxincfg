{
  lib,
  pkgs,
  ...
}:

{
  environment.homeBinInPath = true;

  # Install packages
  environment.systemPackages = [
    pkgs.binutils # for strings
    pkgs.dnsutils # for dig
    pkgs.screen
    pkgs.duf # du replacement on steroids
    pkgs.ncdu
    pkgs.file
    pkgs.jq
    pkgs.killall
    pkgs.unzip
  ];

  # Setup my keyboard layout
  soxin.settings.keyboard = {
    layouts = [
      {
        console = {
          keyMap = "colemak";
        };
      }
    ];
  };

  # --- SYSTEM MAINTENANCE ---
  # Optimize the nix store.
  nix.settings.auto-optimise-store = true;

  # Garbage collection
  nix.gc = {
    automatic = true;
    options = "--delete-older-than 7d";
  };

  services = {
    # Feed the kernel some entropy
    haveged.enable = true;

    # Explicitly disable the X server, sound, dbus, and related services.
    xserver.enable = false;
    pulseaudio.enable = false;
    dbus.enable = lib.mkForce false;
  };

  # Explicitly disable rtkit and polkit (headless — no GUI auth needed)
  security.rtkit.enable = false;
  security.polkit.enable = lib.mkForce false;

  # Disable documentation to save space.
  documentation.enable = false;
  documentation.nixos.enable = false;
}
