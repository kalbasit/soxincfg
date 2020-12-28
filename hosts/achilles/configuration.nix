{ config, lib, nixos-hardware, pkgs, soxincfg, ... }:
with lib;
let
  buildVM = pkgs.callPackage ../zeus/build-vm.nix { };

  buildXML = vmName: memory: hostNic: mac: pkgs.substituteAll {
    src = ../zeus/nixos.xml;

    name = vmName;

    mac_address = mac;

    source_volume = "${vmName}-root.qcow2";

    memory_kb = 4 * 1024 * 1024;

    source_dev = "wlp82s0";
  };

in
{
  imports = [
    soxincfg.nixosModules.profiles.workstation
    soxincfg.nixosModules.profiles.myself

    nixos-hardware.nixosModules.common-cpu-intel
    nixos-hardware.nixosModules.common-pc-laptop
    nixos-hardware.nixosModules.common-pc-ssd

    ./hardware-configuration.nix
  ];

  # load YL's home-manager configuration
  home-manager.users.yl = import ./home.nix { inherit soxincfg; };

  soxin.hardware.intelBacklight.enable = true;

  # speed up the trackpad
  services.xserver.libinput.enable = true;
  services.xserver.libinput.accelSpeed = "0.5";

  system.stateVersion = "20.09";

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
