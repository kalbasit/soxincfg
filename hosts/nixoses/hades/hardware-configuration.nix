{ lib, pkgs, ... }:

with lib;
let
  rootDevice = "/dev/disk/by-uuid/3e59e17d-9dff-4931-9f32-ab77e53c9f01";
  bootDevice = "/dev/disk/by-uuid/CA50-980F";
  swapDevice = "/dev/disk/by-uuid/a3e2591f-a1d4-4d75-b09c-094416b485c4";
  storgeDevice = "/dev/disk/by-uuid/d8a3aad7-3fe8-4986-acc5-c6f7525c9af4";

  subVolumes =
    {
      # NixOS
      "/yl/storage" = { device = storgeDevice; subvol = "@home-kalbasit-storage"; };
    };

  mkBtrfsSubvolume = mountPoint: { device, subvol, options ? [ ] }:
    nameValuePair
      (mountPoint)
      ({
        inherit device;
        fsType = "btrfs";
        options =
          [ "subvol=${subvol}" ]
          ++ options;
      });

in
{
  # Common firmware, i.e. for wifi cards
  hardware.enableRedistributableFirmware = true;

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "usbhid" "sd_mod" ];
  boot.kernelModules = [ "kvm-intel" ];

  boot.loader.grub = {
    configurationLimit = 30;
    device = "nodev";
    efiSupport = true;
    enable = true;
    enableCryptodisk = true;
    useOSProber = true;
  };

  # Fix for Scarlet Focusrite
  boot.extraModprobeConfig = "options snd_usb_audio vid=0x1235 pid=0x8210 device_setup=1";
  boot.kernelPackages=pkgs.linuxPackages_5_11;
  boot.kernelPatches =
  let
    focusrite-scarlett-backports=pkgs.fetchFromGitHub{
      owner="sadko4u";
      repo="focusrite-scarlett-backports";
      rev="97ab71438152ab4665005419fa131cf6d9958495";
      sha256="sha256-WfOrVXUa9khLc1+Wc1aoC568nbZ1tBo3ODhzneb4lTc=";
    };

    in singleton {
    name = "focusrite-scarlett-backports";
    patch = "${focusrite-scarlett-backports}/vanilla-linux-5.11.1-scarlett-gen3.patch";
  };

  boot.loader.efi.canTouchEfiVariables = true;

  boot.loader.systemd-boot.enable = false;

  nix.maxJobs = 1;

  powerManagement.cpuFreqGovernor = "powersave";

  services.xserver.videoDrivers = mkForce [ "modesetting" ];

  console.font = "Lat2-Terminus16";

  boot.initrd.luks.devices = {
    cryptkey = { device = "/dev/disk/by-uuid/3830842b-a589-45e0-a51d-4ed516472575"; };
    cryptroot = { device = "/dev/disk/by-uuid/ec133595-6294-4756-95ea-3891297f6477"; keyFile = "/dev/mapper/cryptkey"; };
    cryptswap = { device = "/dev/disk/by-uuid/71aab354-3872-4316-a26c-b4090d73275c"; keyFile = "/dev/mapper/cryptkey"; };
    cryptstorage = { device = "/dev/disk/by-uuid/d339f141-7544-44d4-89ec-312af0e087cc"; keyFile = "/dev/mapper/cryptkey"; };
  };

  fileSystems = mergeAttrs
    (mapAttrs' mkBtrfsSubvolume subVolumes)
    {
      # NixOS

      "/" = { device = rootDevice; fsType = "ext4"; };
      "/boot" = { device = bootDevice; fsType = "vfat"; };

      # Storage

      "/mnt/volumes/storage" = { device = storgeDevice; fsType = "btrfs"; };
    };

  swapDevices = [{ device = swapDevice; }];
}
