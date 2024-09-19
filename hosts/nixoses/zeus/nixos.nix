{ soxincfg, ... }:

{
  imports = [
    soxincfg.nixosModules.profiles.server

    ./hardware-configuration.nix
  ];

  # Don't allow systemd to stop the Tailscale service because that wreck havoc
  # on my network and containers.
  systemd.services.tailscaled.restartIfChanged = false;

  services.k3s.extraFlags = builtins.concatStringsSep " " [
    #"--node-label nasreddine.com/has-octoprint-device=yes"
  ];
  #soxincfg.services.k3s = {
  #  enable = true;
  #  role = "agent";
  #  serverAddr = "https://192.168.50.16:6443";
  #};
}
