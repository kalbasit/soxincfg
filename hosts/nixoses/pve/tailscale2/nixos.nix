let
  advertiseRoutes = [
    "192.168.10.0/24"
    "192.168.12.0/24"
    "192.168.30.0/24"
    "192.168.50.0/24"
    "192.168.52.0/22"
    "192.168.60.0/24"
    "192.168.61.0/24"
    "192.168.62.0/24"
    "192.168.63.0/24"
    "192.168.250.0/24"
  ];
in
{
  imports = [
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

  services.tailscale = {
    disableTaildrop = true;
    extraSetFlags = [
      "--advertise-routes=${builtins.concatStringsSep "," advertiseRoutes}"
      "--snat-subnet-routes=true"
    ];
    useRoutingFeatures = "both";
  };
}
