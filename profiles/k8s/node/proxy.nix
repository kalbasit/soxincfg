{ config, ... }:

{
  services.kubernetes.proxy = {
    enable = true;
    hostname = config.networking.fqdn;

    kubeconfig = {
      server = "https://172.28.7.10:6443";
      caFile = config.sops.secrets.kubernetes_ca_cert.path;
      certFile = config.sops.secrets.kube_proxy_apiserver_client_cert.path;
      keyFile = config.sops.secrets.kube_proxy_apiserver_client_key.path;
    };
  };

  sops.secrets =
    let
      inherit (config.networking) fqdn;
      sopsFile = ../certs/kube-proxy.yml;
      commonSopsConfig = {
        inherit sopsFile;
      };
    in
    {
      kube_proxy_apiserver_client_cert = commonSopsConfig;
      kube_proxy_apiserver_client_key = commonSopsConfig;
    };
}
