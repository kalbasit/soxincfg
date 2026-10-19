{
  # hardware
  intelBacklight = {
    nixos = ./hardware/intel-backlight/nixos.nix;
    darwin = ./hardware/intel-backlight/darwin.nix;
    home = ./hardware/intel-backlight/home.nix;
  };
  lowbatt = {
    nixos = ./hardware/lowbatt/nixos.nix;
    darwin = ./hardware/lowbatt/darwin.nix;
    home = ./hardware/lowbatt/home.nix;
  };
  serial_console = {
    nixos = ./hardware/serial_console/nixos.nix;
    darwin = ./hardware/serial_console/darwin.nix;
    home = ./hardware/serial_console/home.nix;
  };
  sound = {
    nixos = ./hardware/sound/nixos.nix;
    darwin = ./hardware/sound/darwin.nix;
    home = ./hardware/sound/home.nix;
  };

  # services
  caffeine = {
    nixos = ./services/caffeine/nixos.nix;
    darwin = ./services/caffeine/darwin.nix;
    home = ./services/caffeine/home.nix;
  };
  dunst = {
    nixos = ./services/dunst/nixos.nix;
    darwin = ./services/dunst/darwin.nix;
    home = ./services/dunst/home.nix;
  };
  i3 = {
    nixos = ./services/x11/window-managers/i3/nixos.nix;
    darwin = ./services/x11/window-managers/i3/darwin.nix;
    home = ./services/x11/window-managers/i3/home.nix;
  };
  networkmanager = {
    nixos = ./services/networking/networkmanager/nixos.nix;
    darwin = ./services/networking/networkmanager/darwin.nix;
    home = ./services/networking/networkmanager/home.nix;
  };
  polybar = {
    nixos = ./services/x11/window-managers/bar/nixos.nix;
    darwin = ./services/x11/window-managers/bar/darwin.nix;
    home = ./services/x11/window-managers/bar/home.nix;
  };
  printing = {
    nixos = ./services/printing/nixos.nix;
    darwin = ./services/printing/darwin.nix;
    home = ./services/printing/home.nix;
  };
  sshd = {
    nixos = ./services/networking/ssh/sshd/nixos.nix;
    darwin = ./services/networking/ssh/sshd/darwin.nix;
    home = ./services/networking/ssh/sshd/home.nix;
  };
  xserver = {
    nixos = ./services/x11/xserver/nixos.nix;
    darwin = ./services/x11/xserver/darwin.nix;
    home = ./services/x11/xserver/home.nix;
  };

  # virtualisation
  docker = {
    nixos = ./virtualisation/docker/nixos.nix;
    darwin = ./virtualisation/docker/darwin.nix;
    home = ./virtualisation/docker/home.nix;
  };
  libvirtd = {
    nixos = ./virtualisation/libvirtd/nixos.nix;
    darwin = ./virtualisation/libvirtd/darwin.nix;
    home = ./virtualisation/libvirtd/home.nix;
  };
  virtualbox = {
    nixos = ./virtualisation/virtualbox/nixos.nix;
    darwin = ./virtualisation/virtualbox/darwin.nix;
    home = ./virtualisation/virtualbox/home.nix;
  };
}
