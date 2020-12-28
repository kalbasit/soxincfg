{ nixpkgs, config, lib, ... }:

{
  imports = [
    ./flannel.nix
    ./kubelet.nix
    ./proxy.nix
  ];

  boot.kernelPackages = lib.mkForce nixpkgs.linuxPackages_latest;

  boot.supportedFilesystems = [ "nfs" ];

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = true;
    "net.ipv4.conf.ens3.send_redirects" = false;
    "net.ipv6.conf.all.forwarding" = true;
    "net.ipv4.ip_nonlocal_bind" = true;
    "net.ipv4.conf.lxc*.rp_filter" = 0;
  };

  environment.persistence."/persist" = {
    directories = [
      "/var/lib/docker"
      "/var/lib/kubernetes"
      "/var/lib/etcd"
      "/var/lib/cfssl"
      "/var/lib/kubelet"
    ];
  };

  networking = {
    useDHCP = false;
    dhcpcd.enable = false;
    firewall.allowedTCPPorts = [
      7946
      7472 # metallb
    ];
  };

  virtualisation.docker.autoPrune = {
    enable = true;
    dates = "daily";
    flags = [ "--all" ];
  };

  sops.validateSopsFiles = false;
  sops.secrets.kubernetes_ca_cert = {
    sopsFile = ../certs/kubernetes-ca-cert.yml;
    owner = "kubernetes";
  };

  users.users.kubernetes.extraGroups = [ config.users.groups.keys.name ];
}
