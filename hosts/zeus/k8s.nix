{ config, lib, modules, pkgs, soxincfg, ... }:
with lib;
let
  buildVM = pkgs.callPackage ./build-vm.nix { };

  buildXML = vmName: memory: hostNic: mac: pkgs.substituteAll {
    src = ./nixos.xml;

    name = vmName;

    mac_address = mac;

    source_volume = "${vmName}-root.qcow2";

    memory_kb = 4 * 1024 * 1024;

    source_dev = "ifcsn0";
  };
in
{
  soxincfg.virtualisation.libvirtd = {
    enable = true;
    images = singleton "nixos";
  };
  systemd.services.libvirtd-guest-k8s-master-1 = buildVM rec {
    vmName = "k8s-master-1";
    xml = buildXML vmName "8" "ifcsn0" "50:00:00:00:00:01";
    baseDisk = { image = "/etc/libvirtd/base-images/nixos.qcow2"; diskSize = 50; };
  };
}
