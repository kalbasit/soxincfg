{
  # hardware
  onlykey = ./hardware/onlykey;
  yubikey = ./hardware/yubikey;

  # programs
  android = ./programs/android.nix;
  autorandr = ./programs/autorandr.nix;
  brave = ./programs/brave.nix;
  chromium = ./programs/chromium;
  dbeaver = ./programs/dbeaver;
  fzf = ./programs/fzf;
  git = ./programs/git;
  mosh = ./programs/mosh;
  neovim = ./programs/neovim;
  pet = ./programs/pet;
  rofi = ./programs/rofi;
  ssh = ./programs/ssh;
  starship = ./programs/starship.nix;
  termite = ./programs/termite.nix;
  tmux = ./programs/tmux;
  weechat = ./programs/weechat;
  wezterm = ./programs/wezterm;
  zsh = ./programs/zsh;

  # services
  borders = ./services/borders;
  dnsmasq = ./services/dnsmasq;
  i3 = ./services/x11/window-managers/i3.nix;
  iscsid = ./services/iscsid.nix;
  k3s = ./services/k3s;
  nextcloud = ./services/nextcloud;
  sketchybar = ./services/sketchybar;
  skhd = ./services/skhd;
  sleep-on-lan = ./services/sleep-on-lan;
  twingate = ./services/networking/twingate.nix;
  yabai = ./services/yabai;

  # settings
  fonts = ./settings/fonts;
  gtk = ./settings/gtk;
  keyboard = ./settings/keyboard;
  networking = ./settings/networking;
  nix = ./settings/nix;
  users = ./settings/users;
  home-manager-settings = ./settings/home-manager;
}
