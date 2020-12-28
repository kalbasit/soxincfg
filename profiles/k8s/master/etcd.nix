{ config, lib, ... }:
let
  nodeIP = (lib.head config.networking.interfaces.ens3.ipv4.addresses).address;
in
{
  networking.firewall.allowedTCPPorts = [ 2379 2380 ];

  services.etcd = {
    enable = true;
    name = config.networking.hostName;
    initialAdvertisePeerUrls = [
      "https://${nodeIP}:2380"
    ];
    listenPeerUrls = [
      "https://${nodeIP}:2380"
    ];
    listenClientUrls = [
      "https://127.0.0.1:2379"
      "https://${nodeIP}:2379"
    ];
    advertiseClientUrls = [
      "https://${nodeIP}:2379"
    ];
    initialClusterToken = "etcd.k8s.fsn.lama-corp.space";
    initialCluster = [
      "master-11=https://172.28.7.11:2380"
      "master-12=https://172.28.7.12:2380"
      "master-13=https://172.28.7.13:2380"
    ];
    initialClusterState = "new";

    clientCertAuth = true;
    trustedCaFile = config.sops.secrets.etcd_ca_cert.path;
    certFile = config.sops.secrets.etcd_server_cert.path;
    keyFile = config.sops.secrets.etcd_server_key.path;

    peerClientCertAuth = true;
    peerTrustedCaFile = config.sops.secrets.etcd_ca_cert.path;
    peerCertFile = config.sops.secrets.etcd_peer_cert.path;
    peerKeyFile = config.sops.secrets.etcd_peer_key.path;
  };

  sops.secrets =
    let
      inherit (config.networking) fqdn;
      owner = config.systemd.services.etcd.serviceConfig.User;
      sopsFile = "${toString ../certs}/etcd-${fqdn}.yml";
      commonSopsConfig = {
        inherit owner sopsFile;
      };
    in
    {
      etcd_ca_cert = {
        inherit owner;
        group = config.users.groups.keys.name;
        mode = "0440";
        sopsFile = ../certs/etcd-ca-cert.yml;
      };
      etcd_server_cert = commonSopsConfig;
      etcd_server_key = commonSopsConfig;
      etcd_peer_cert = commonSopsConfig;
      etcd_peer_key = commonSopsConfig;
    };

  systemd.services.etcd = {
    serviceConfig.SupplementaryGroups = [ config.users.groups.keys.name ];
  };
}
