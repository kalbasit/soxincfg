{
  # programs
  android = ./programs/android.nix;
  autorandr = ./programs/autorandr.nix;
  brave = ./programs/brave.nix;
  chromium = ./programs/chromium;
  dbeaver = ./programs/dbeaver;
  git = ./programs/git.nix;
  ssh = ./programs/ssh.nix;
  starship = ./programs/starship.nix;
  weechat = ./programs/weechat;

  # services
  dnsmasq = ./services/dnsmasq;
  i3 = ./services/x11/window-managers/i3.nix;
  iscsid = ./services/iscsid.nix;

  # settings
  nix = ./settings/nix;
}
