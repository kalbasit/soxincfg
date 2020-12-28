{ config, pkgs, lib, ... }:

{
  services.kubernetes.scheduler = {
    enable = true;
    kubeconfig = {
      server = "https://172.28.7.10:6443";
      caFile = config.sops.secrets.kubernetes_ca_cert.path;
      certFile = config.sops.secrets.scheduler_apiserver_client_cert.path;
      keyFile = config.sops.secrets.scheduler_apiserver_client_key.path;
    };
  };

  sops.secrets =
    let
      owner = config.systemd.services.kube-scheduler.serviceConfig.User;
      sopsFile = ../certs/scheduler.yml;
      commonSopsConfig = {
        inherit owner sopsFile;
      };
    in
    {
      scheduler_apiserver_client_cert = commonSopsConfig;
      scheduler_apiserver_client_key = commonSopsConfig;
    };

  systemd.services.kube-scheduler = {
    serviceConfig.SupplementaryGroups = [ config.users.groups.keys.name ];
  };
}
