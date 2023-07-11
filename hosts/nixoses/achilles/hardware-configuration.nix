{ lib, pkgs, nixos-hardware, ... }:

with lib;

{
  imports = [
    nixos-hardware.nixosModules.common-pc-laptop
    nixos-hardware.nixosModules.lenovo-thinkpad-p1-gen3
  ];

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

  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.loader.efi.canTouchEfiVariables = true;

  boot.loader.systemd-boot.enable = false;

  nix.settings.max-jobs = lib.mkDefault 8;

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  # HiDPI settings
  console.font = "${pkgs.terminus_font}/share/consolefonts/ter-v32n.psf.gz";
  console.earlySetup = true; # Needed when typing in passwords for full disk encryption
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

    # SoxinCFG secrets
    "/yl/code/repositories/github.com/kalbasit/soxincfg/profiles/work/secret-store" = { device = "/yl/code/repositories/keybase/private/ylcodes/secrets/soxincfg/work/secret-store"; options = [ "bind" ]; };
  };

  swapDevices = [{ device = "/dev/mapper/cryptswap"; }];
}
