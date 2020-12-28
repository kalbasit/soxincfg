{ config, ... }:

{
  services.kubernetes.controllerManager = {
    enable = true;

    rootCaFile = config.sops.secrets.kubernetes_ca_cert.path;
    tlsCertFile = config.sops.secrets.controller_manager_cert.path;
    tlsKeyFile = config.sops.secrets.controller_manager_key.path;

    serviceAccountKeyFile = config.sops.secrets.service_account_key.path;

    kubeconfig = {
      server = "https://172.28.7.10:6443";
      caFile = config.sops.secrets.kubernetes_ca_cert.path;
      certFile = config.sops.secrets.controller_manager_apiserver_client_cert.path;
      keyFile = config.sops.secrets.controller_manager_apiserver_client_key.path;
    };
  };

  sops.secrets =
    let
      owner = config.systemd.services.kube-controller-manager.serviceConfig.User;
      sopsFile = ../certs/controller-manager.yml;
      commonSopsConfig = {
        inherit owner sopsFile;
      };
    in
    {
      controller_manager_cert = commonSopsConfig;
      controller_manager_key = commonSopsConfig;
      controller_manager_apiserver_client_cert = commonSopsConfig;
      controller_manager_apiserver_client_key = commonSopsConfig;
    };

  systemd.services.kube-controller-manager = {
    serviceConfig.SupplementaryGroups = [ config.users.groups.keys.name ];
  };
}
