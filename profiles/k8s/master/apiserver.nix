{ config, pkgs, lib, ... }:
let
  nodeIP = (lib.head config.networking.interfaces.ens3.ipv4.addresses).address;
in
{
  services.kubernetes.apiserverAddress = "https://172.28.7.10:6443";
  services.kubernetes.apiserver = {
    enable = true;
    advertiseAddress = "172.28.7.10";
    bindAddress = nodeIP;
    allowPrivileged = true;

    clientCaFile = config.sops.secrets.kubernetes_ca_cert.path;
    tlsCertFile = config.sops.secrets.apiserver_server_cert.path;
    tlsKeyFile = config.sops.secrets.apiserver_server_key.path;

    etcd = {
      servers = [
        "https://172.28.7.11:2379"
        "https://172.28.7.12:2379"
        "https://172.28.7.13:2379"
      ];
      caFile = config.sops.secrets.etcd_ca_cert.path;
      certFile = config.sops.secrets.apiserver_etcd_client_cert.path;
      keyFile = config.sops.secrets.apiserver_etcd_client_key.path;
    };

    kubeletClientCaFile = config.sops.secrets.kubernetes_ca_cert.path;
    kubeletClientCertFile = config.sops.secrets.apiserver_kubelet_client_cert.path;
    kubeletClientKeyFile = config.sops.secrets.apiserver_kubelet_client_key.path;

    proxyClientCertFile = config.sops.secrets.apiserver_proxy_client_cert.path;
    proxyClientKeyFile = config.sops.secrets.apiserver_proxy_client_key.path;

    serviceAccountKeyFile = config.sops.secrets.service_account_key.path;
  };

  sops.secrets =
    let
      owner = config.systemd.services.kube-apiserver.serviceConfig.User;
      sopsFile = ../certs/apiserver.yml;
      commonSopsConfig = {
        inherit owner sopsFile;
      };
    in
    {
      apiserver_server_cert = commonSopsConfig;
      apiserver_server_key = commonSopsConfig;

      apiserver_etcd_client_cert = commonSopsConfig;
      apiserver_etcd_client_key = commonSopsConfig;

      apiserver_kubelet_client_cert = commonSopsConfig;
      apiserver_kubelet_client_key = commonSopsConfig;

      apiserver_proxy_client_cert = commonSopsConfig;
      apiserver_proxy_client_key = commonSopsConfig;

      service_account_key = {
        inherit owner;
        sopsFile = ../certs/service-account.yml;
      };
    };

  systemd.services.kube-apiserver = {
    serviceConfig.SupplementaryGroups = [ config.users.groups.keys.name ];
  };
}
