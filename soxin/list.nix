{
  # settings
  fonts = ./settings/fonts.nix;
  gtk = ./settings/gtk.nix;
  theme = ./settings/theme;
  users = ./settings/users.nix;

  # programs
  autorandr = ./programs/autorandr.nix;
  fzf = ./programs/fzf.nix;
  git = ./programs/git.nix;
  htop = ./programs/htop.nix;
  keybase = ./programs/keybase.nix;
  mosh = ./programs/mosh.nix;
  neovim = ./programs/neovim;
  rofi = ./programs/rofi;
  ssh = ./programs/ssh.nix;
  starship = ./programs/starship.nix;
  tmux = ./programs/tmux;
  urxvt = ./programs/urxvt.nix;
  zsh = ./programs/zsh;

  # hardware
  hardware = ./services/hardware/default.nix;
  intelBacklight = ./services/hardware/intel-backlight.nix;
  lowbatt = ./services/hardware/lowbatt.nix;
  sound = ./services/hardware/sound.nix;
  yubikey = ./services/hardware/yubikey.nix;

  # services
  caffeine = ./services/caffeine.nix;
  dunst = ./services/dunst.nix;
  gpgAgent = ./services/gpg-agent.nix;
  i3 = ./services/x11/window-managers/i3;
  locker = ./services/locker.nix;
  polybar = ./services/x11/window-managers/bar;
  printing = ./services/printing.nix;
  sshd = ./services/networking/ssh/sshd.nix;
  xserver = ./services/x11/xserver.nix;
  weechat = ./services/weechat.nix;

  # virtualisation
  docker = ./virtualisation/docker.nix;
  libvirtd = ./virtualisation/libvirtd.nix;
}
