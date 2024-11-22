{
  config,
  lib,
  pkgs,
  soxincfg,
  ...
}:

with lib;
let
  unifi_config_gateway =
    let
      config = { };
    in
    pkgs.writeText "config.gateway.json" (builtins.toJSON config);
in
{
  # Unifi now runs on the Kubernetes cluster

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
