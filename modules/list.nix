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
  ssh = ./programs/ssh;
  starship = ./programs/starship.nix;
  termite = ./programs/termite.nix;
  tmux = ./programs/tmux;
  weechat = ./programs/weechat;
  wezterm = ./programs/wezterm;
  zsh = ./programs/zsh;

  # services
  dnsmasq = ./services/dnsmasq;
  i3 = ./services/x11/window-managers/i3.nix;
  iscsid = ./services/iscsid.nix;
  nextcloud = ./services/nextcloud;

  # settings
  fonts = ./settings/fonts;
  gtk = ./settings/gtk;
  keyboard = ./settings/keyboard;
  nix = ./settings/nix;
  users = ./settings/users;
  home-manager-settings = ./settings/home-manager;
}
