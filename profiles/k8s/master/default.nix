{ config, pkgs, lib, ... }:

{
  imports = [
    ./keepalived.nix
    ./haproxy.nix

    ./etcd.nix

    ./addon-manager.nix
    ./addons
    ./apiserver.nix
    ./controller-manager.nix
    ./kubelet.nix
    ./scheduler.nix
  ];
}
