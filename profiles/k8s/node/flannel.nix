{ config, lib, ... }:

{
  /*services.kubernetes.flannel.enable = false;
  services.kubernetes.kubelet = {
    networkPlugin = "cni";
    cni.configDir = "/etc/cni/net.d";
  };

  systemd.services.kubelet.preStart = lib.mkForce ''
    ${lib.concatMapStrings (img: ''
      echo "Seeding docker image: ${img}"
      docker load <${img}
    '') config.services.kubernetes.kubelet.seedDockerImages}

    ${lib.concatMapStrings (package: ''
      echo "Linking cni package: ${package}"
      ln -fs ${package}/bin/* /opt/cni/bin
    '') config.services.kubernetes.kubelet.cni.packages}
  '';

  networking.dhcpcd.denyInterfaces = [ "cilium*" "lxc*" "docker*" ];
  networking.firewall = {
    allowedTCPPorts = [
      4240
      4244
      4245
      6942
      9090
      9876
    ];
    allowedUDPPorts = [
      8472
    ];
  };*/

  services.kubernetes.flannel.enable = true;
  services.flannel = {
    kubeconfig = config.services.kubernetes.lib.mkKubeConfig "flannel" {
      server = "https://172.28.7.10:6443";
      caFile = config.sops.secrets.kubernetes_ca_cert.path;
      certFile = config.sops.secrets.flannel_apiserver_client_cert.path;
      keyFile = config.sops.secrets.flannel_apiserver_client_key.path;
    };
  };

  sops.secrets =
    let
      sopsFile = ../certs/flannel.yml;
      commonSopsConfig = {
        inherit sopsFile;
      };
    in
    {
      flannel_apiserver_client_cert = commonSopsConfig;
      flannel_apiserver_client_key = commonSopsConfig;
    };
}
