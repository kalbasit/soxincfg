{ config, lib, pkgs, ... }:

{
  # Common firmware, i.e. for wifi cards
  hardware.enableRedistributableFirmware = true;

  # Use the extlinux boot loader. (NixOS wants to enable GRUB by default)
  boot.loader.grub.enable = false;
  # Enables the generation of /boot/extlinux/extlinux.conf
  boot.loader.generic-extlinux-compatible.enable = true;

  boot.loader.raspberryPi.enable = true;
  boot.loader.raspberryPi.version = 3;
  boot.loader.raspberryPi.uboot.enable = true;
  boot.loader.raspberryPi.firmwareConfig = "force_turbo=1";

  boot.kernelParams = [ "console=ttyS1,115200n8" ];

  fileSystems."/" =
    {
      device = "/dev/disk/by-uuid/44444444-4444-4444-8888-888888888888";
      fsType = "ext4";
    };

  swapDevices = [{ device = "/var/swapfile"; size = 4096; }];

  nix.maxJobs = lib.mkDefault 4;
}
