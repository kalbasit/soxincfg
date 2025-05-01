{
  config,
  lib,
  pkgs,
  ...
}:

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
    # https://kubernetes.io/docs/reference/networking/ports-and-protocols
    networking.firewall.allowedTCPPorts =
      [
        80 # HTTP
        443 # HTTPS

        1883 # MQTT

        9100 # Prometheus

        10250 # Kubelet metrics
      ]
      ++ optionals (cfg.role == "server") [
        6443 # k3s: required so that pods can reach the API server (running on port 6443 by default)
      ];

    networking.firewall.allowedUDPPorts = [
      8472 # k3s, flannel: required for VXLAN
    ];

    # Error seen in Cloudflared
    # https://github.com/quic-go/quic-go/wiki/UDP-Buffer-Sizes
    boot.kernel.sysctl = {
      "net.core.rmem_max" = 7500000;
      "net.core.wmem_max" = 7500000;
    };

    environment.systemPackages = singleton config.services.k3s.package;

    services.k3s = mkMerge [
      {
        inherit (cfg) enable role serverAddr;
        tokenFile = config.sops.secrets.services-k3s-tokenFile.path;
        nofile = 1024 * 1024 * 2;
      }

      (mkIf (cfg.role == "server") {
        environmentFile = config.sops.secrets.services-k3s-environmentFile.path;
      })
    ];

    sops.secrets = mkMerge [
      {
        "services-k3s-tokenFile" = {
          inherit sopsFile;
        };
      }

      (mkIf (cfg.role == "server") {
        "services-k3s-environmentFile" = {
          inherit sopsFile;
        };
      })
    ];
  };
}
