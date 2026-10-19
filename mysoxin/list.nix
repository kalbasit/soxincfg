{
  # hardware
  intelBacklight = ./hardware/intel-backlight.nix;
  lowbatt = ./hardware/lowbatt.nix;
  serial_console = {
    nixos = ./hardware/serial_console/nixos.nix;
    darwin = ./hardware/serial_console/darwin.nix;
    home = ./hardware/serial_console/home.nix;
  };
  sound = ./hardware/sound.nix;

  # services
  caffeine = ./services/caffeine.nix;
  dunst = ./services/dunst.nix;
  i3 = ./services/x11/window-managers/i3;
  networkmanager = ./services/networking/networkmanager.nix;
  polybar = ./services/x11/window-managers/bar;
  printing = ./services/printing.nix;
  sshd = ./services/networking/ssh/sshd.nix;
  xserver = ./services/x11/xserver.nix;

  # virtualisation
  docker = ./virtualisation/docker;
  libvirtd = ./virtualisation/libvirtd.nix;
  virtualbox = ./virtualisation/virtualbox.nix;
}
