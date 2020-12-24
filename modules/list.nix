{
  # programs
  autorandr = ./programs/autorandr.nix;
  brave = ./programs/brave.nix;
  chromium = ./programs/chromium;
  git = ./programs/git.nix;
  ssh = ./programs/ssh.nix;
  starship = ./programs/starship.nix;

  # services
  i3 = ./services/x11/window-managers/i3.nix;
  dnsmasq = ./services/dnsmasq;

  # settings
  nix = ./settings/nix;
}
