{ lib, pkgs, ... }:

with lib;

{
  # Common firmware, i.e. for wifi cards
  hardware.enableRedistributableFirmware = true;

  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" "sdhci_pci" ];
  boot.kernelModules = [ "kvm-intel" ];

  boot.loader.grub = {
    configurationLimit = 30;
    device = "nodev";
    efiSupport = true;
    enable = true;
    enableCryptodisk = true;
  };

  boot.loader.systemd-boot.enable = false;

  nix.maxJobs = lib.mkDefault 8;

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  # HiDPI settings
  console.font = "${pkgs.terminus_font}/share/consolefonts/ter-v32n.psf.gz";
  console.earlySetup = true; # Needed when typing in passwords for full disk encryption
  fonts.fontconfig.dpi = 196;
  services.xserver.dpi = 196;
  services.xserver.synaptics.minSpeed = "1.0";
  services.xserver.synaptics.maxSpeed = "1.5";

  boot.initrd.luks.devices = {
    cryptkey = { device = "/dev/disk/by-uuid/5993d93d-faa4-4007-9be2-d6a037c015eb"; };
    cryptroot = { device = "/dev/disk/by-uuid/cd596953-67cc-49eb-be2f-095c8e9e5706"; keyFile = "/dev/mapper/cryptkey"; };
    cryptswap = { device = "/dev/disk/by-uuid/eaec1f89-16fa-48ad-8cb9-11124545bb01"; keyFile = "/dev/mapper/cryptkey"; };
  };

  fileSystems = {
    "/" = { device = "/dev/mapper/cryptroot"; fsType = "ext4"; };
    "/boot" = { device = "/dev/disk/by-uuid/AE56-BDC8"; fsType = "vfat"; };
  };

  swapDevices = [{ device = "/dev/mapper/cryptswap"; }];
}
