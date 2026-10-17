# A module is a path, imported by every kind, or, once it no longer
# switches on `mode`, an attribute set of its nixos, darwin and home modules.
{
  # hardware
  onlykey = ./hardware/onlykey;
  yubikey = ./hardware/yubikey;

  # programs
  android = {
    nixos = ./programs/android/nixos.nix;
    darwin = ./programs/android/darwin.nix;
    home = ./programs/android/home.nix;
  };
  autorandr = ./programs/autorandr.nix;
  brave = ./programs/brave.nix;
  chromium = ./programs/chromium;
  claude-code = ./programs/claude-code;
  codex = ./programs/codex;
  dbeaver = ./programs/dbeaver;
  fzf = {
    nixos = ./programs/fzf/options.nix;
    darwin = ./programs/fzf/options.nix;
    home = ./programs/fzf/home.nix;
  };
  git = ./programs/git;
  iterm2 = ./programs/iterm2;
  maktab = ./programs/maktab;
  mosh = {
    nixos = ./programs/mosh/nixos.nix;
    darwin = ./programs/mosh/options.nix;
    home = ./programs/mosh/home.nix;
  };
  nazir = ./programs/nazir;
  neovim = ./programs/neovim;
  pet = ./programs/pet;
  rofi = ./programs/rofi;
  secretive = {
    nixos = ./programs/secretive/options.nix;
    darwin = ./programs/secretive/darwin.nix;
    home = ./programs/secretive/options.nix;
  };
  ssh = ./programs/ssh;
  starship = {
    nixos = ./programs/starship/nixos.nix;
    darwin = ./programs/starship/darwin.nix;
    home = ./programs/starship/home.nix;
  };
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
  dnsmasq = {
    nixos = ./services/dnsmasq/nixos.nix;
    darwin = ./services/dnsmasq/options.nix;
    home = ./services/dnsmasq/options.nix;
  };
  i3 = ./services/x11/window-managers/i3.nix;
  iscsid = {
    nixos = ./services/iscsid/nixos.nix;
    darwin = ./services/iscsid/options.nix;
    home = ./services/iscsid/options.nix;
  };
  nextcloud = ./services/nextcloud;
  sleep-on-lan = ./services/sleep-on-lan;
  ssh-agent-mux = {
    nixos = ./services/ssh-agent-mux/options.nix;
    darwin = ./services/ssh-agent-mux/darwin.nix;
    home = ./services/ssh-agent-mux/options.nix;
  };

  # settings
  fonts = ./settings/fonts;
  gtk = ./settings/gtk;
  keyboard = ./settings/keyboard;
  networking = ./settings/networking;
  nix = ./settings/nix;
  users = ./settings/users;
  home-manager-settings = ./settings/home-manager;
}
