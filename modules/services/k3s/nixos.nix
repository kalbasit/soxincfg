{ config, pkgs, ... }:

let
  inherit (lib)
    mkMerge
    optionals
    ;

  cfg = config.soxincfg.services.k3s;
  sopsFile = ./secrets.sops.yaml;
in
{
  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts =
      [ 6443 ] # k3s: required so that pods can reach the API server (running on port 6443 by default)
      ++ optionals (config.soxincfg.services.k3s.role == "server") [
        2379 # k3s, etcd clients: required if using a "High Availability Embedded etcd" configuration
        2380 # k3s, etcd peers: required if using a "High Availability Embedded etcd" configuration
      ];

    networking.firewall.allowedUDPPorts =
      optionals (config.soxincfg.services.k3s.role == "server") [
        8472 # k3s, flannel: required if using multi-node for inter-node networking
      ];

    environment.systemPackages = [ pkgs.k3s ];

    services.k3s = mkMerge [
      {
        enable = true;
        role = cfg.role;
        serverAddr = cfg.serverAddr;
        tokenFile = config.sops.secrets.services-k3s-tokenFile.path;
      }

      (mkIf (cfg.role == "server") {
        clusterInit = true;
      })
    ];


    sops.secrets = {
      "services-k3s-tokenFile" = { inherit sopsFile; };
    };
  };
}
