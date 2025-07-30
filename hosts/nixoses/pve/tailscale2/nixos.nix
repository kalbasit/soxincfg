{ soxincfg, ... }:

{
  imports = [
    soxincfg.profiles.tailscale.subnet-router

    ../nixos-25.05/nixos.nix
  ];

  networking.firewall.allowedTCPPorts = [ 53 ];
  networking.firewall.allowedUDPPorts = [ 53 ];

  services.dnsmasq = {
    enable = true;

    resolveLocalQueries = false;

    settings = {
      # Listen on the local LAN interface.
      # listen-address=127.0.0.1,192.168.100.7

      # Forward ALL queries to Tailscale's resolver. It will handle the rest.
      server = [ "100.100.100.100" ];

      # Do not read /etc/resolv.conf.
      no-resolv = true;

      # Cache up to n entries
      cache-size = "10000";
    };
  };
}
