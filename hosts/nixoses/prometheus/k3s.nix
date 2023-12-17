{ config, soxincfg, modulesPath, pkgs, ... }:

let
  sopsFile = ./secrets.sops.yaml;
in
{
  networking.firewall.allowedTCPPorts = [
    6443 # k3s: required so that pods can reach the API server (running on port 6443 by default)
    # 2379 # k3s, etcd clients: required if using a "High Availability Embedded etcd" configuration
    # 2380 # k3s, etcd peers: required if using a "High Availability Embedded etcd" configuration
  ];
  networking.firewall.allowedUDPPorts = [
    # 8472 # k3s, flannel: required if using multi-node for inter-node networking
  ];

  environment.systemPackages = [ pkgs.k3s ];

  services.k3s = {
    clusterInit = true;
    enable = true;
    role = "server";
    # tokenFile = config.sops.secrets.services-k3s-tokenFile.path;
  };

  sops.secrets = {
    # "services-k3s-tokenFile" = { inherit sopsFile; };
  };
}
