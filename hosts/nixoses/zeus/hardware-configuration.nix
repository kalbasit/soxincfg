{ config, lib, pkgs, ... }:
let
  exports = [
    "Anime"
    "Cartoon"
    "Code"
    "Documentaries"
    "Downloads"
    "Imported"
    "Mail"
    "Movies"
    "MusicVideos"
    "Plays"
    "Plex"
    "Stand-upComedy"
    "TVShows"
    "docker"
    "music"
  ];

  toFSEntry = export: lib.nameValuePair "/nas/${export}" {
    device = "192.168.50.2:/volume1/${export}";
    fsType = "nfs";
  };

  nfsFSEntries = builtins.listToAttrs (map toFSEntry exports);

in
{
  # Common firmware, i.e. for wifi cards
  hardware.enableRedistributableFirmware = true;

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
  boot.kernelModules = [ "kvm-intel" "iscsi_tcp" ];

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

  nix.maxJobs = lib.mkDefault 12;

  soxin.hardware.serial_console.enable = true;

  console.font = "Lat2-Terminus16";

  boot.initrd.luks.devices = {
    cryptkey = {
      device = "/dev/disk/by-uuid/df87bcdc-1456-49be-ab44-b483cf7f064c";
    };

    cryptroot = {
      device = "/dev/disk/by-uuid/5703b200-33e6-4c61-b99a-78e7e806f437";
      keyFile = "/dev/mapper/cryptkey";
    };

    # cryptswap = {
    #   device = "/dev/disk/by-uuid/509f93b9-65cb-4886-b6eb-797697373a7d";
    #   keyFile = "/dev/mapper/cryptkey";
    # };
    #
    # cryptstorage = {
    #   device = "/dev/disk/by-uuid/1bb05e34-5aa0-419b-a6c0-2574b7566832";
    #   keyFile = "/dev/mapper/cryptkey";
    # };
  };

  fileSystems = nfsFSEntries // {
    "/" = {
      device = "/dev/disk/by-uuid/471c4bf2-14c9-4eef-a791-8beebfcfe31a";
      fsType = "btrfs";
      options = [ "subvol=@nixos/@root" ];
    };

    # "/home" = {
    #   device = "/dev/disk/by-uuid/471c4bf2-14c9-4eef-a791-8beebfcfe31a";
    #   fsType = "btrfs";
    #   options = [ "subvol=@nixos/@home" ];
    # };
    #
    # "/yl/code" = {
    #   device = "/dev/disk/by-uuid/471c4bf2-14c9-4eef-a791-8beebfcfe31a";
    #   fsType = "btrfs";
    #   options = [ "subvol=@code" ];
    # };
    #
    # "/yl/private" = {
    #   device = "/dev/disk/by-uuid/471c4bf2-14c9-4eef-a791-8beebfcfe31a";
    #   fsType = "btrfs";
    #   options = [ "subvol=@private" ];
    # };

    "/boot" = {
      device = "/dev/disk/by-uuid/8590-9053";
      fsType = "vfat";
    };
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/f58da878-7e18-430e-ad8c-321f63c61a4e"; }
  ];
}
