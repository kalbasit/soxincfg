{
  # programs
  autorandr = ./programs/autorandr.nix;
  brave = ./programs/brave.nix;
  chromium = ./programs/chromium;
  git = ./programs/git.nix;
  ssh = ./programs/ssh.nix;
  starship = ./programs/starship.nix;

  # services
  dnsmasq = ./services/dnsmasq;
  i3 = ./services/x11/window-managers/i3.nix;
  iscsid = ./services/iscsid.nix;

  # settings
  nix = ./settings/nix;
}
