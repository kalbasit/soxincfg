{ config, ... }:

{
  networking.firewall.allowedTCPPorts = [ 10250 ];
  services.kubernetes.kubelet = {
    enable = true;
    hostname = config.networking.fqdn;

    clientCaFile = config.sops.secrets.kubernetes_ca_cert.path;

    kubeconfig = {
      server = "https://172.28.7.10:6443";
      caFile = config.sops.secrets.kubernetes_ca_cert.path;
      certFile = config.sops.secrets.kubelet_apiserver_client_cert.path;
      keyFile = config.sops.secrets.kubelet_apiserver_client_key.path;
    };

    tlsCertFile = config.sops.secrets.kubelet_cert.path;
    tlsKeyFile = config.sops.secrets.kubelet_key.path;
  };

  sops.secrets =
    let
      inherit (config.networking) fqdn;
      sopsFile = "${toString ../certs}/kubelet-${fqdn}.yml";
      commonSopsConfig = {
        inherit sopsFile;
      };
    in
    {
      kubelet_cert = commonSopsConfig;
      kubelet_key = commonSopsConfig;
      kubelet_apiserver_client_cert = commonSopsConfig;
      kubelet_apiserver_client_key = commonSopsConfig;
    };
}
