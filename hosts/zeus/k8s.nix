{ config, lib, modules, pkgs, soxincfg, ... }:
with lib;
let
  buildVM = pkgs.callPackage ./build-vm.nix { };

  buildXML = vmName: memory: hostNic: mac:
    pkgs.writeText "libvirt-guest-${vmName}.xml" ''
      <domain type="kvm">
        <vmName>${vmName}</vmName>
        <uuid>UUID</uuid>
        <os>
          <type>hvm</type>
        </os>
        <memory unit="GiB">${memory}</memory>
        <devices>
          <disk type="volume">
            <source volume="guest-${vmName}"/>
            <target dev="vda" bus="virtio"/>
          </disk>
          <graphics type="spice" autoport="yes"/>
          <input type="keyboard" bus="usb"/>
          <interface type="direct">
            <source dev="${hostNic}" mode="bridge"/>
            <mac address="${mac}"/>
            <model type="virtio"/>
          </interface>
        </devices>
        <features>
          <acpi/>
        </features>
      </domain>
    '';
in
{
  systemd.services.libvirtd-guest-k8s-master-1 = buildVM rec {
    vmName = "k8s-master-1";
    xml = buildXML vmName "8" "ifcsn0" "50:00:00:00:00:01";
  };
}
