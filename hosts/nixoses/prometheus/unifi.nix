{ config, lib, pkgs, soxincfg, ... }:

with lib;
let
  unifi_config_gateway =
    let
      config = { };
    in
    pkgs.writeText "config.gateway.json" (builtins.toJSON config);
in
{
  # enable unifi and open the remote port
  services.unifi = {
    enable = true;
    jrePackage = pkgs.jdk21_headless;
    unifiPackage = pkgs.unifi;
    # XXX: Leaving this in case I need to update it again.
    # unifiPackage = pkgs.unifiStable.overrideAttrs (oa: rec {
    #   version = "6.0.43";
    #   name = "unifi-controller-${version}";
    #
    #   src = pkgs.fetchurl {
    #     url = "https://dl.ubnt.com/unifi/${version}/unifi_sysvinit_all.deb";
    #     sha256 = "sha256-fsqjA61JAIEeLiADAkOjI2ynmD93kNXDkiRfIBzhN7U=";
    #   };
    # });
  };
  systemd.services.unifi.preStart = ''
    mkdir -p /var/lib/unifi/data/sites/default
    ln -nsf ${unifi_config_gateway} /var/lib/unifi/data/sites/default/config.gateway.json
  '';

  # Allow unifi controller inform on all interfaces
  networking.firewall.allowedTCPPorts = [
    53 # UniFi DNS
    6789 # UniFi mobile speed test
    8080 # UniFi Inform port
    8443 # uniFi UI
  ];

  networking.firewall.allowedUDPPorts = [
    53 # UniFi DNS
    123 # NTP
    1900 # UniFi used to "Make application discoverable on L2 network" in the UniFi Network settings.
    3478 # UniFi STUN
    5514 # UniFi remote syslog
    10001 # UniFi device discovery
  ];
}
