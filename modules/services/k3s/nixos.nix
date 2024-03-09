{ config, lib, pkgs, ... }:

let
  inherit (lib)
    mkIf
    mkMerge
    optionals
    singleton
    ;

  cfg = config.soxincfg.services.k3s;
  sopsFile = ./secrets.sops.yaml;
in
{
  imports = [
    ./longhorn-support.nix
    ./nfs-support.nix
  ];

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts =
      [
        80 # HTTP
        443 # HTTPS

        1883 # MQTT
      ] ++ optionals (cfg.role == "server") [
        6443 # k3s: required so that pods can reach the API server (running on port 6443 by default)
        2379 # k3s, etcd clients: required if using a "High Availability Embedded etcd" configuration
        2380 # k3s, etcd peers: required if using a "High Availability Embedded etcd" configuration
      ];

    networking.firewall.allowedUDPPorts =
      [
        8472 # k3s, flannel: required if using multi-node for inter-node networking
        10250 # k3s, metrics.
      ];

    environment.systemPackages = singleton config.services.k3s.package;

    services.k3s = mkMerge [
      {
        inherit (cfg) enable role serverAddr;
        tokenFile = config.sops.secrets.services-k3s-tokenFile.path;
      }

      (mkIf (cfg.role == "server") {
        environmentFile = config.sops.secrets.services-k3s-environmentFile.path;
      })
    ];

    sops.secrets = mkMerge [
      {
        "services-k3s-tokenFile" = { inherit sopsFile; };
      }

      (mkIf (cfg.role == "server") {
        "services-k3s-environmentFile" = { inherit sopsFile; };
      })
    ];
  };
}
