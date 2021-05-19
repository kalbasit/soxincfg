{
  # programs
  android = ./programs/android.nix;
  autorandr = ./programs/autorandr.nix;
  brave = ./programs/brave.nix;
  chromium = ./programs/chromium;
  dbeaver = ./programs/dbeaver;
  git = ./programs/git.nix;
  neovim = ./programs/neovim;
  ssh = ./programs/ssh.nix;
  starship = ./programs/starship.nix;
  termite = ./programs/termite.nix;
  tmux = ./programs/tmux;
  weechat = ./programs/weechat;
  zsh = ./programs/zsh;

  # services
  dnsmasq = ./services/dnsmasq;
  i3 = ./services/x11/window-managers/i3.nix;
  iscsid = ./services/iscsid.nix;
  nextcloud = ./services/nextcloud;

  # settings
  nix = ./settings/nix;
}
