{ config, lib, modules, pkgs, soxincfg, ... }:
with lib;
let
  buildVM = pkgs.callPackage ./build-vm.nix { };

  buildMasterVM = id:
    let
      vmName = "k8s-master-${id}";
    in
    buildVM {
      inherit vmName;

      baseDisk = {
        image = "/etc/libvirtd/base-images/nixos.qcow2";
        diskSize = 50;
      };

      xml = pkgs.substituteAll {
        src = ./nixos.xml;
        inherit vmName;

        diskSourceFile = "/srv/vms/guest_local_images/${vmName}-root.qcow2";
        hostNic = "ifcsn0";
        macAddress = "50:00:00:00:00:0${id}";
        memoryKB = 4 * 1024 * 1024;
      };
    };

in
{
  soxincfg.virtualisation.libvirtd = {
    enable = true;
    images = singleton "nixos";
  };

  systemd.services = attrsets.genAttrs [ "1" "2" "3" ] buildMasterVM;
}
