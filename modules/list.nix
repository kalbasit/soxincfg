# A module is a path, imported by every kind, or, once it no longer
# switches on `mode`, an attribute set of its nixos, darwin and home modules.
{
  # hardware
  onlykey = {
    nixos = ./hardware/onlykey/nixos.nix;
    darwin = ./hardware/onlykey/darwin.nix;
    home = ./hardware/onlykey/home.nix;
  };
  yubikey = {
    nixos = ./hardware/yubikey/nixos.nix;
    darwin = ./hardware/yubikey/darwin.nix;
    home = ./hardware/yubikey/home.nix;
  };

  # programs
  android = {
    nixos = ./programs/android/nixos.nix;
    darwin = ./programs/android/darwin.nix;
    home = ./programs/android/home.nix;
  };
  autorandr = {
    nixos = ./programs/autorandr/nixos.nix;
    darwin = ./programs/autorandr/darwin.nix;
    home = ./programs/autorandr/home.nix;
  };
  chromium = {
    nixos = ./programs/chromium/nixos.nix;
    darwin = ./programs/chromium/darwin.nix;
    home = ./programs/chromium/home.nix;
  };
  claude-code = {
    nixos = ./programs/claude-code/nixos.nix;
    darwin = ./programs/claude-code/darwin.nix;
    home = ./programs/claude-code/home.nix;
  };
  codex = {
    nixos = ./programs/codex/nixos.nix;
    darwin = ./programs/codex/darwin.nix;
    home = ./programs/codex/home.nix;
  };
  dbeaver = {
    nixos = ./programs/dbeaver/nixos.nix;
    darwin = ./programs/dbeaver/darwin.nix;
    home = ./programs/dbeaver/home.nix;
  };
  fzf = {
    nixos = ./programs/fzf/options.nix;
    darwin = ./programs/fzf/options.nix;
    home = ./programs/fzf/home.nix;
  };
  git = {
    nixos = ./programs/git/nixos.nix;
    darwin = ./programs/git/darwin.nix;
    home = ./programs/git/home.nix;
  };
  iterm2 = {
    nixos = ./programs/iterm2/nixos.nix;
    darwin = ./programs/iterm2/darwin.nix;
    home = ./programs/iterm2/home.nix;
  };
  private-tool = {
    nixos = ./programs/private-tool/nixos.nix;
    darwin = ./programs/private-tool/darwin.nix;
    home = ./programs/private-tool/home.nix;
  };
  private-tool = {
    nixos = ./programs/private-tool/nixos.nix;
    darwin = ./programs/private-tool/darwin.nix;
    home = ./programs/private-tool/home.nix;
  };
  neovim = {
    nixos = ./programs/neovim/nixos.nix;
    darwin = ./programs/neovim/darwin.nix;
    home = ./programs/neovim/home.nix;
  };
  pet = {
    nixos = ./programs/pet/nixos.nix;
    darwin = ./programs/pet/darwin.nix;
    home = ./programs/pet/home.nix;
  };
  rofi = {
    nixos = ./programs/rofi/nixos.nix;
    darwin = ./programs/rofi/darwin.nix;
    home = ./programs/rofi/home.nix;
  };
  ssh = {
    nixos = ./programs/ssh/nixos.nix;
    darwin = ./programs/ssh/darwin.nix;
    home = ./programs/ssh/home.nix;
  };
  starship = {
    nixos = ./programs/starship/nixos.nix;
    darwin = ./programs/starship/darwin.nix;
    home = ./programs/starship/home.nix;
  };
  termite = {
    nixos = ./programs/termite/nixos.nix;
    darwin = ./programs/termite/darwin.nix;
    home = ./programs/termite/home.nix;
  };
  tmux = {
    nixos = ./programs/tmux/nixos.nix;
    darwin = ./programs/tmux/darwin.nix;
    home = ./programs/tmux/home.nix;
  };
  vscode = {
    nixos = ./programs/vscode/nixos.nix;
    darwin = ./programs/vscode/darwin.nix;
    home = ./programs/vscode/home.nix;
  };
  weechat = {
    nixos = ./programs/weechat/nixos.nix;
    darwin = ./programs/weechat/darwin.nix;
    home = ./programs/weechat/home.nix;
  };
  wezterm = {
    nixos = ./programs/wezterm/nixos.nix;
    darwin = ./programs/wezterm/darwin.nix;
    home = ./programs/wezterm/home.nix;
  };
  zed = {
    nixos = ./programs/zed/nixos.nix;
    darwin = ./programs/zed/darwin.nix;
    home = ./programs/zed/home.nix;
  };
  zellij = {
    nixos = ./programs/zellij/nixos.nix;
    darwin = ./programs/zellij/darwin.nix;
    home = ./programs/zellij/home.nix;
  };
  zsh = {
    nixos = ./programs/zsh/nixos.nix;
    darwin = ./programs/zsh/darwin.nix;
    home = ./programs/zsh/home.nix;
  };

  # services
  aerospace = {
    nixos = ./services/aerospace/nixos.nix;
    darwin = ./services/aerospace/darwin.nix;
    home = ./services/aerospace/home.nix;
  };
  dnsmasq = {
    nixos = ./services/dnsmasq/nixos.nix;
    darwin = ./services/dnsmasq/options.nix;
    home = ./services/dnsmasq/options.nix;
  };
  i3 = {
    nixos = ./services/x11/window-managers/i3/nixos.nix;
    darwin = ./services/x11/window-managers/i3/darwin.nix;
    home = ./services/x11/window-managers/i3/home.nix;
  };
  iscsid = {
    nixos = ./services/iscsid/nixos.nix;
    darwin = ./services/iscsid/options.nix;
    home = ./services/iscsid/options.nix;
  };
  nextcloud = {
    nixos = ./services/nextcloud/nixos.nix;
    darwin = ./services/nextcloud/darwin.nix;
    home = ./services/nextcloud/home.nix;
  };
  sleep-on-lan = {
    nixos = ./services/sleep-on-lan/nixos.nix;
    darwin = ./services/sleep-on-lan/darwin.nix;
    home = ./services/sleep-on-lan/home.nix;
  };
  ssh-agent-mux = {
    nixos = ./services/ssh-agent-mux/options.nix;
    darwin = ./services/ssh-agent-mux/darwin.nix;
    home = ./services/ssh-agent-mux/options.nix;
  };

  # settings
  fonts = {
    nixos = ./settings/fonts/nixos.nix;
    darwin = ./settings/fonts/darwin.nix;
    home = ./settings/fonts/home.nix;
  };
  gtk = {
    nixos = ./settings/gtk/nixos.nix;
    darwin = ./settings/gtk/darwin.nix;
    home = ./settings/gtk/home.nix;
  };
  keyboard = {
    nixos = ./settings/keyboard/nixos.nix;
    darwin = ./settings/keyboard/darwin.nix;
    home = ./settings/keyboard/home.nix;
  };
  networking = {
    nixos = ./settings/networking/nixos.nix;
    darwin = ./settings/networking/darwin.nix;
    home = ./settings/networking/home.nix;
  };
  nix = {
    nixos = ./settings/nix/nixos.nix;
    darwin = ./settings/nix/darwin.nix;
    home = ./settings/nix/home.nix;
  };
  users = {
    nixos = ./settings/users/nixos.nix;
    darwin = ./settings/users/darwin.nix;
    home = ./settings/users/home.nix;
  };
  home-manager-settings = {
    nixos = ./settings/home-manager/nixos.nix;
    darwin = ./settings/home-manager/darwin.nix;
    home = ./settings/home-manager/home.nix;
  };
}
