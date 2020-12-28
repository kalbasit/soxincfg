{ config, pkgs, lib, ... }:

{
  services.kubernetes.addonManager.enable = true;

  systemd.services.kube-addon-manager = {
    environment.KUBECONFIG = config.services.kubernetes.lib.mkKubeConfig "addon-manager" {
      server = "https://172.28.7.10:6443";
      caFile = config.sops.secrets.kubernetes_ca_cert.path;
      certFile = config.sops.secrets.addon_manager_apiserver_client_cert.path;
      keyFile = config.sops.secrets.addon_manager_apiserver_client_key.path;
    };
    #serviceConfig.PermissionsStartOnly = true;
    preStart =
      let
        files = lib.mapAttrsToList (n: v: pkgs.writeText "${n}.json" (builtins.toJSON v))
          config.services.kubernetes.addonManager.bootstrapAddons;
        clusterAdminKubeconfig = config.services.kubernetes.lib.mkKubeConfig "cluster-admin" {
          server = "https://172.28.7.10:6443";
          caFile = config.sops.secrets.kubernetes_ca_cert.path;
          certFile = config.sops.secrets.cluster_admin_cert.path;
          keyFile = config.sops.secrets.cluster_admin_key.path;
        };
      in
      ''
        export KUBECONFIG=${clusterAdminKubeconfig}
        ${pkgs.kubectl}/bin/kubectl apply -f ${lib.concatStringsSep " \\\n -f " files}
      '';
  };

  sops.secrets =
    let
      owner = config.systemd.services.kube-addon-manager.serviceConfig.User;
      sopsFile = ../certs/addon-manager.yml;
      commonSopsConfig = {
        inherit owner sopsFile;
      };
    in
    {
      addon_manager_apiserver_client_cert = commonSopsConfig;
      addon_manager_apiserver_client_key = commonSopsConfig;

      cluster_admin_cert = {
        inherit owner;
        sopsFile = ../certs/cluster-admin.yml;
      };
      cluster_admin_key = {
        inherit owner;
        sopsFile = ../certs/cluster-admin.yml;
      };
    };

  systemd.services.kube-addon-manager = {
    serviceConfig.SupplementaryGroups = [ config.users.groups.keys.name ];
  };
}
