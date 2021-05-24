{
  # programs
  ssh = ./programs/ssh.nix;
  starship = ./programs/starship.nix;
  urxvt = ./programs/urxvt.nix;

  # hardware
  fwupd = ./hardware/fwupd.nix;
  intelBacklight = ./hardware/intel-backlight.nix;
  lowbatt = ./hardware/lowbatt.nix;
  serial_console = ./hardware/serial_console.nix;
  sound = ./hardware/sound.nix;
  yubikey = ./hardware/yubikey.nix;

  # services
  caffeine = ./services/caffeine.nix;
  dunst = ./services/dunst.nix;
  gpgAgent = ./services/gpg-agent.nix;
  i3 = ./services/x11/window-managers/i3;
  locker = ./services/locker.nix;
  networkmanager = ./services/networking/networkmanager.nix;
  polybar = ./services/x11/window-managers/bar;
  printing = ./services/printing.nix;
  sshd = ./services/networking/ssh/sshd.nix;
  xserver = ./services/x11/xserver.nix;

  # virtualisation
  docker = ./virtualisation/docker.nix;
  libvirtd = ./virtualisation/libvirtd.nix;
  virtualbox = ./virtualisation/virtualbox.nix;
}
