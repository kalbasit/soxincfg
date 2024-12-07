{
  config,
  soxincfg,
  modulesPath,
  pkgs,
  ...
}:
{
  imports = [
    soxincfg.nixosModules.profiles.server

    ./containers.nix
    ./hardware-configuration.nix
    ./unifi.nix
    ./k3s.nix
  ];

  soxin.hardware.lowbatt.enable = true;

  environment.systemPackages =
    let
      inherit (pkgs) nfs-utils speedtest-cli;
    in
    [
      nfs-utils
      speedtest-cli
    ];

  # Don't allow systemd to stop the Tailscale service because that wreck havoc
  # on my network and containers.
  systemd.services.tailscaled.restartIfChanged = false;

  # Disable firewall for now
  # TODO: Fix the issue and re-enable the firewall.
  # When the firewall is open, I can't reach the right ports on the ifcsn0
  # interface. It's possible that I need to define that on the interface
  # directly.
  networking.firewall.enable = false;

  system.stateVersion = "23.05";
}
