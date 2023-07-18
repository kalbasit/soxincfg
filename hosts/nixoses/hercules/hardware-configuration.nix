{ lib, pkgs, ... }:

with lib;
let
  bootDevice = "/dev/disk/by-uuid/E1F2-2DEC";
  swap0Device = "/dev/disk/by-uuid/0e5232f4-2f60-41fb-a11a-2867bf3686a2";
  swap1Device = "/dev/disk/by-uuid/8415c540-ae09-4716-bfc5-02e5b83ec73b";

  datasets = {
    "/" = { device = "rpool/nixos/root"; };
    "/home" = { device = "rpool/nixos/home"; };
    "/var" = { device = "rpool/nixos/var"; };
    "/var/lib" = { device = "rpool/nixos/var/lib"; };
    "/var/log" = { device = "rpool/nixos/var/log"; };
    "/yl" = { device = "rpool/nixos/yl"; };
    "/yl/code" = { device = "rpool/nixos/yl/code"; };
  };

  mkZFSDataSet = mountPoint: { device }:
    nameValuePair
      (mountPoint)
      ({ inherit device; fsType = "zfs"; });

in
{
  # Common firmware, i.e. for wifi cards
  hardware.enableRedistributableFirmware = true;

  # ZFS requires a networking hostId
  networking.hostId = "4a92c82f";

  boot.initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" "vmd" "nvme" "usbhid" "usb_storage" "sd_mod" ];
  boot.kernelModules = [ "kvm-intel" ];

  boot.loader.grub = {
    configurationLimit = 30;
    device = "nodev";
    efiSupport = true;
    enable = true;
    enableCryptodisk = true;
  };

  # enable focusrite Gen3 support.
  soxin.hardware.sound.focusRiteGen3Support = true;

  boot.loader.efi.canTouchEfiVariables = true;

  boot.loader.systemd-boot.enable = false;

  nix.settings.max-jobs = 3;

  powerManagement.cpuFreqGovernor = "powersave";

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.opengl.enable = true;

  # nvidia-drm.modeset=1 is required for some wayland compositors, e.g. sway
  hardware.nvidia.modesetting.enable = true;

  console.font = "Lat2-Terminus16";

  boot.initrd.luks.devices = {
    cryptkey = { device = "/dev/disk/by-uuid/f6d83931-7313-490f-90b9-f337f7663015"; };
    cryptroot0 = { device = "/dev/disk/by-uuid/c27c971e-8ba9-42c3-b75a-e89ccdc2e701"; keyFile = "/dev/mapper/cryptkey"; };
    cryptroot1 = { device = "/dev/disk/by-uuid/127feb77-bf29-4b76-be64-cf1c7fafaeea"; keyFile = "/dev/mapper/cryptkey"; };
    cryptswap0 = { device = "/dev/disk/by-uuid/fdd38250-eed9-45bf-9e2b-38b94de6a740"; keyFile = "/dev/mapper/cryptkey"; };
    cryptswap1 = { device = "/dev/disk/by-uuid/adbe4611-bb18-43da-9a02-c660f9575e8b"; keyFile = "/dev/mapper/cryptkey"; };
  };

  fileSystems = mergeAttrs
    (mapAttrs' mkZFSDataSet datasets)
    {
      "/boot" = { device = bootDevice; fsType = "vfat"; };

      # SoxinCFG secrets
      "/yl/code/repositories/github.com/kalbasit/soxincfg/profiles/work/secret-store" = { device = "/yl/code/repositories/keybase/private/ylcodes/secrets/soxincfg/work/secret-store"; options = [ "bind" ]; };
    };

  swapDevices = [
    { device = swap0Device; }
    { device = swap1Device; }
  ];
}
