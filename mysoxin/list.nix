{
  # hardware
  fwupd = ./hardware/fwupd.nix;
  intelBacklight = ./hardware/intel-backlight.nix;
  lowbatt = ./hardware/lowbatt.nix;
  rtl-sdr = ./hardware/rtl-sdr;
  serial_console = ./hardware/serial_console.nix;
  sound = ./hardware/sound.nix;
  zsa = ./hardware/zsa;

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
