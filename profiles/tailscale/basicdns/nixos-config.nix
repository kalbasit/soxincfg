{
  config,
  lib,
  pkgs,
  ...
}:

let
  # The keepalived Virtual IP
  virtual_ip = "192.168.20.20/24";

  # The interface keepalived is running on
  vrrp_interface = "ens18";
in
{
  # Allow traffic on port 53
  networking.firewall.allowedTCPPorts = [ 53 ];
  networking.firewall.allowedUDPPorts = [ 53 ];

  services = {
    # Enable keepalived
    keepalived = {
      enable = true;

      vrrpInstances.dns_vip = {
        interface = vrrp_interface;

        virtualRouterId = 20;
        virtualIps = [
          { addr = virtual_ip; }
        ];
        trackScripts = lib.attrNames config.services.keepalived.vrrpScripts;
      };

      vrrpScripts = {
        check_unbound_process = {
          fall = 1;
          interval = 3;
          user = "root";
          weight = 20;

          script =
            let
              script = pkgs.writeShellScript "check-unbound-process.sh" ''
                set -eo pipefail
                ${lib.getExe' pkgs.procps "pidof"} unbound
              '';
            in
            builtins.toString script;
        };

        check_unbound_liveness = {
          fall = 1;
          interval = 3;
          user = "root";
          weight = 20;

          script =
            let
              script = pkgs.writeShellScript "check-unbound-liveness.sh" ''
                set -eo pipefail
                ${lib.getExe' pkgs.dnsutils "dig"} @127.0.0.1 -p 53 google.com +time=1 | ${lib.getExe pkgs.gnugrep} -q 'status: NOERROR'
              '';
            in
            builtins.toString script;
        };
      };
    };

    # Enable Tailscale so DNSMasq can call to Tailscale DNS directly.
    tailscale.enable = true;

    # Enable Unbound for DNS
    unbound = {
      enable = true;

      resolveLocalQueries = false;

      settings = {
        forward-zone = [
          {
            name = "bigeye-bushi.ts.net";
            forward-addr = "100.100.100.100";
          }

          {
            name = ".";
            forward-tls-upstream = true;

            # NextDNS DoQ servers with TLS authentication
            # The format is IP@port#<your-config-id>.dns.nextdns.io
            forward-addr = [
              "45.90.28.0#96893a.dns1.nextdns.io"
              "2a07:a8c0::#96893a.dns1.nextdns.io"
              "45.90.30.0#96893a.dns2.nextdns.io"
              "2a07:a8c1::#96893a.dns2.nextdns.io"
            ];
          }
        ];

        remote-control = {
          control-enable = true;
          control-interface = "127.0.0.1";
        };

        server = {
          # General and security options
          interface = [ "0.0.0.0" ];
          interface-automatic = true; # Allow replying from the VIP configured by KeepAlived
          access-control = "192.168.0.0/16 allow";
          do-ip4 = true;
          do-udp = true;
          do-tcp = true;

          # Caching options
          cache-min-ttl = 3600; # Serve stale data for an hour if upstream is down
          cache-max-ttl = 86400; # Cache records for up to a day
          prefetch = true; # Refreshes popular items before they expire
          prefetch-key = true; # Use DNSKEY to validate pre-fetched records
        };
      };
    };
  };
}
