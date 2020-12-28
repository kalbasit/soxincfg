{ pkgs ? import <nixpkgs> { }, config ? import ./config.nix }:
let
  lib = pkgs.lib;

  kubernetes-ca = import ./ca.nix {
    inherit pkgs lib config;
    name = "kubernetes";
  };

  etcd-ca = import ./ca.nix {
    inherit pkgs lib config;
    name = "etcd";
    dirPrefix = "etcd";
  };

  certs-etcd = import ./etcd.nix {
    inherit pkgs lib config;
    etcd-ca = "${etcd-ca}/etcd";
    dirPrefix = "etcd";
  };

  certs-cilium = import ./cilium.nix {
    inherit pkgs lib config;
    etcd-ca = "${etcd-ca}/etcd";
  };

  certs-etcd-healthcheck-client = import ./etcd-healthcheck-client.nix {
    inherit pkgs lib config;
    etcd-ca = "${etcd-ca}/etcd";
  };

  certs-apiserver = import ./apiserver.nix {
    inherit pkgs lib config kubernetes-ca;
    etcd-ca = "${etcd-ca}/etcd";
  };

  certs-service-account = import ./serviceAccount.nix {
    inherit pkgs lib config kubernetes-ca;
  };

  certs-scheduler = import ./scheduler.nix {
    inherit pkgs lib config kubernetes-ca;
  };

  certs-controller-manager = import ./controller-manager.nix {
    inherit pkgs lib config kubernetes-ca;
  };

  certs-addon-manager = import ./addon-manager.nix {
    inherit pkgs lib config kubernetes-ca;
  };

  certs-kube-proxy = import ./kube-proxy.nix {
    inherit pkgs lib config kubernetes-ca;
  };

  certs-kubelet = import ./kubelet.nix {
    inherit pkgs lib config kubernetes-ca;
  };

  certs-flannel = import ./flannel.nix {
    inherit pkgs lib config kubernetes-ca;
  };

  certs-cluster-admin = import ./cluster-admin.nix {
    inherit pkgs lib config kubernetes-ca;
  };
in
pkgs.symlinkJoin {
  name = "certs";
  paths = [
    kubernetes-ca
    etcd-ca
    certs-etcd
    certs-apiserver
    certs-service-account
    certs-scheduler
    certs-controller-manager
    certs-addon-manager
    certs-kube-proxy
    certs-kubelet
    certs-flannel
    certs-cluster-admin
    certs-cilium
    certs-etcd-healthcheck-client
  ];
}
