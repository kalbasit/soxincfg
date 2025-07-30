{
  lib,
  pkgs,
  ...
}:

{
  # Allow traffic on port 53
  networking.firewall.allowedTCPPorts = [ 53 ];
  networking.firewall.allowedUDPPorts = [ 53 ];

  services = {
    # Enable dnsmasq
    dnsmasq = {
      enable = true;

      resolveLocalQueries = false;

      settings = {
        # Forward ALL queries to Tailscale's resolver. It will handle the rest.
        server = [ "100.100.100.100" ];

        # Do not read /etc/resolv.conf.
        no-resolv = true;

        # Cache up to n entries
        cache-size = "10000";
      };
    };

    # Enable keepalived
    keepalived = {
      enable = true;

      vrrpScripts = {
        check_dnsmasq_process = {
          script = "${lib.getExe' pkgs.procps "pidof"} dnsmasq";
          user = "root";
          weight = 20;
        };

        check_dnsmasq_liveness = {
          script = "${lib.getExe' pkgs.dnsutils "dig"} @127.0.0.1 -p 53 google.com +time=1 | ${lib.getExe pkgs.gnugrep} -q 'status: NOERROR'";
          user = "root";
          weight = 20;
        };
      };
    };

    # Enable Tailscale so DNSMasq can call to Tailscale DNS directly.
    tailscale.enable = true;
  };
}
