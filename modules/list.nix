{
  # hardware
  onlykey = ./hardware/onlykey;
  yubikey = ./hardware/yubikey;

  # programs
  android = ./programs/android.nix;
  autorandr = ./programs/autorandr.nix;
  brave = ./programs/brave.nix;
  chromium = ./programs/chromium;
  claude-code = ./programs/claude-code;
  codex = ./programs/codex;
  dbeaver = ./programs/dbeaver;
  fzf = ./programs/fzf;
  git = ./programs/git;
  iterm2 = ./programs/iterm2;
  mosh = ./programs/mosh;
  neovim = ./programs/neovim;
  pet = ./programs/pet;
  rofi = ./programs/rofi;
  secretive = ./programs/secretive;
  ssh = ./programs/ssh;
  starship = ./programs/starship.nix;
  swm = ./programs/swm;
  t3code = ./programs/t3code;
  termite = ./programs/termite.nix;
  tmux = ./programs/tmux;
  vscode = ./programs/vscode;
  weechat = ./programs/weechat;
  wezterm = ./programs/wezterm;
  zed = ./programs/zed;
  zellij = ./programs/zellij;
  zsh = ./programs/zsh;

  # services
  aerospace = ./services/aerospace;
  dnsmasq = ./services/dnsmasq;
  i3 = ./services/x11/window-managers/i3.nix;
  iscsid = ./services/iscsid.nix;
  nextcloud = ./services/nextcloud;
  sleep-on-lan = ./services/sleep-on-lan;
  ssh-agent-mux = ./services/ssh-agent-mux;

  # settings
  fonts = ./settings/fonts;
  gtk = ./settings/gtk;
  keyboard = ./settings/keyboard;
  networking = ./settings/networking;
  nix = ./settings/nix;
  users = ./settings/users;
  home-manager-settings = ./settings/home-manager;
}
