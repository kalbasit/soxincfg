{ config, lib, pkgs, ... }:

let
  inherit (lib)
    mkDefault
    nameValuePair
    mergeAttrs
    mapAttrs'
    ;

  bootDevice = "/dev/disk/by-uuid/733F-28F5";
  swapDevice = "/dev/disk/by-uuid/85587a1b-57cc-4d9c-bf7e-7abb4bdd2060";
  windowsDevice = "/dev/disk/by-uuid/28C025C1C025965A";

  datasets = {
    # NixOS
    "/" = { device = "olympus/system/nixos/root"; };
    "/nix" = { device = "olympus/system/nixos/nix"; };
    "/var" = { device = "olympus/system/nixos/var"; };
    "/yl" = { device = "olympus/user/yl/nixos-home"; };
    "/yl/code" = { device = "olympus/user/yl/code"; };

    ## Arch Linux
    # Arch Linux within NixOS
    "/mnt/arch" = { device = "olympus/system/arch/root"; };
    "/mnt/arch/nix" = { device = "olympus/system/arch/nix"; };
    "/mnt/arch/var" = { device = "olympus/system/arch/var"; };
    "/mnt/arch/yl" = { device = "olympus/user/yl/arch-home"; };
    "/mnt/arch/yl/code" = { device = "olympus/user/yl/code"; };

    # NixOS within Arch Linux
    "/mnt/arch/mnt/nixos" = { device = "olympus/system/nixos/root"; };
    "/mnt/arch/mnt/nixos/nix" = { device = "olympus/system/nixos/nix"; };
    "/mnt/arch/mnt/nixos/var" = { device = "olympus/system/nixos/var"; };
    "/mnt/arch/mnt/nixos/yl" = { device = "olympus/user/yl/nixos-home"; };
    "/mnt/arch/mnt/nixos/yl/code" = { device = "olympus/user/yl/code"; };

    ## Ubuntu
    # Ubuntu within NixOS
    "/mnt/ubuntu" = { device = "olympus/system/ubuntu/root"; };
    "/mnt/ubuntu/nix" = { device = "olympus/system/ubuntu/nix"; };
    "/mnt/ubuntu/var" = { device = "olympus/system/ubuntu/var"; };
    "/mnt/ubuntu/yl" = { device = "olympus/user/yl/ubuntu-home"; };
    "/mnt/ubuntu/yl/code" = { device = "olympus/user/yl/code"; };

    # NixOS within Ubuntu
    "/mnt/ubuntu/mnt/nixos" = { device = "olympus/system/nixos/root"; };
    "/mnt/ubuntu/mnt/nixos/nix" = { device = "olympus/system/nixos/nix"; };
    "/mnt/ubuntu/mnt/nixos/var" = { device = "olympus/system/nixos/var"; };
    "/mnt/ubuntu/mnt/nixos/yl" = { device = "olympus/user/yl/nixos-home"; };
    "/mnt/ubuntu/mnt/nixos/yl/code" = { device = "olympus/user/yl/code"; };
  };

  mkZFSDataSet = mountPoint: { device }:
    nameValuePair
      (mountPoint)
      ({ inherit device; fsType = "zfs"; options = [ "relatime" ]; });

  exports = [
    # "Anime"
    # "Cartoon"
    # "Code"
    # "Documentaries"
    # "Downloads"
    # "Imported"
    # "Mail"
    # "Movies"
    # "MusicVideos"
    # "Plays"
    # "Plex"
    # "Stand-upComedy"
    # "TVShows"
    # "docker"
    # "music"
  ];

  toFSEntry = export: nameValuePair "/nas/${export}" {
    device = "192.168.50.2:/volume1/${export}";
    fsType = "nfs";
  };

  nfsFSEntries = builtins.listToAttrs (map toFSEntry exports);
in
{
  # Common firmware, i.e. for wifi cards
  hardware.enableRedistributableFirmware = true;

  # Topology config for routing audio/microphone on Razer laptops
  # copied from https://github.com/eureka-cpu/dotfiles/blob/tensorbook/nixos/configuration.nix
  boot.extraModprobeConfig = ''
    options snd-sof-pci tplg_filename=sof-hda-generic-2ch-pdm1.tplg
  '';

  # ZFS requires a networking hostId
  networking.hostId = "4a92c82f";

  # configure kernel and modules
  boot.initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" "vmd" "nvme" "usbhid" "usb_storage" "sd_mod" "sdhci_pci" ];
  boot.kernelModules = [ "kvm-intel" ];

  # configure boot loader
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot = {
    editor = false;
    enable = true;
    extraEntries = {
      "archlinux.conf" = ''
        title Arch Linux
        sort-key arch
        version Main
        linux /EFI/arch/vmlinuz-linux
        initrd /EFI/arch/initramfs-linux.img
        options spl.spl_hostid=0x4a92c82f cryptdevice=/dev/disk/by-uuid/5f4422ca-eb45-4532-931b-63225c2143d5:cryptroot zfs=olympus/system/arch/root rw
        machine-id eb9cb30c8e1d473e91ef3c792d4af65c
      '';

      "archlinux-fallback.conf" = ''
        title Arch Linux
        sort-key arch
        version Fallback
        linux /EFI/arch/vmlinuz-linux
        initrd /EFI/arch/initramfs-linux-fallback.img
        options spl.spl_hostid=0x4a92c82f cryptdevice=/dev/disk/by-uuid/5f4422ca-eb45-4532-931b-63225c2143d5:cryptroot zfs=olympus/system/arch/root rw
        machine-id eb9cb30c8e1d473e91ef3c792d4af65c
      '';

      "ubuntu.conf" = ''
        title Ubuntu
        sort-key ubuntu
        version Main
        linux /EFI/ubuntu/vmlinuz
        initrd /EFI/ubuntu/initrd.img
        options spl.spl_hostid=0x4a92c82f root=ZFS=olympus/system/arch/root rw
        machine-id eb9cb30c8e1d473e91ef3c792d4af65c
      '';
    };
    configurationLimit = 3;
  };

  # enable focusrite Gen3 support.
  soxin.hardware.sound.focusRiteGen3Support = true;

  nix.settings.max-jobs = 12;

  powerManagement.cpuFreqGovernor = "powersave";

  hardware.cpu.intel.updateMicrocode = mkDefault config.hardware.enableRedistributableFirmware;

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.opengl.enable = true;

  # nvidia-drm.modeset=1 is required for some wayland compositors, e.g. sway
  hardware.nvidia.modesetting.enable = true;

  console.font = "Lat2-Terminus16";

  boot.initrd.luks.devices = {
    cryptkey = { device = "/dev/disk/by-uuid/00f72dbb-eb46-468f-b1c3-dd63adc542f0"; };
    cryptroot = { device = "/dev/disk/by-uuid/5f4422ca-eb45-4532-931b-63225c2143d5"; keyFile = "/dev/mapper/cryptkey"; };
    cryptswap = { device = "/dev/disk/by-uuid/0249ea43-7216-4a9b-9c57-377f22c41bfc"; keyFile = "/dev/mapper/cryptkey"; };
  };

  fileSystems = mergeAttrs
    (mergeAttrs nfsFSEntries (mapAttrs' mkZFSDataSet datasets))
    {
      # Boot device
      "/boot" = { device = bootDevice; fsType = "vfat"; options = [ "fmask=0022" "dmask=0022" ]; };

      # Arch non-zfs mounts
      "/mnt/arch/boot" = { device = bootDevice; fsType = "vfat"; options = [ "fmask=0022" "dmask=0022" ]; };
      "/mnt/arch/dev" = { device = "/dev"; options = [ "bind" ]; };
      "/mnt/arch/dev/pts" = { device = "/dev/pts"; options = [ "bind" ]; };
      "/mnt/arch/proc" = { device = "proc"; fsType = "proc"; };
      "/mnt/arch/sys" = { device = "sys"; fsType = "sysfs"; };

      # Ubuntu non-zfs device
      # TODO: Figure out how to configure Ubuntu where to put kernel instead of the /boot-real /boot hack
      "/mnt/ubuntu/boot" = { device = "/mnt/ubuntu/boot-real/EFI/ubuntu"; options = [ "bind" ]; };
      "/mnt/ubuntu/boot-real" = { device = bootDevice; fsType = "vfat"; options = [ "fmask=0022" "dmask=0022" ]; };
      "/mnt/ubuntu/dev" = { device = "/dev"; options = [ "bind" ]; };
      "/mnt/ubuntu/dev/pts" = { device = "/dev/pts"; options = [ "bind" ]; };
      "/mnt/ubuntu/proc" = { device = "proc"; fsType = "proc"; };
      "/mnt/ubuntu/sys" = { device = "sys"; fsType = "sysfs"; };

      # Windows
      "/mnt/windows" = {
        device = windowsDevice;
        fsType = "ntfs";
        options = [
          "gid=${builtins.toString config.users.groups."${config.users.users.yl.group}".gid}"
          "uid=${builtins.toString config.users.users.yl.uid}"
        ];
      };

      # SoxinCFG secrets
      "/yl/code/repositories/github.com/kalbasit/soxincfg/profiles/work/secret-store" = {
        device = "/yl/code/repositories/keybase/private/ylcodes/secrets/soxincfg/work/secret-store";
        options = [ "bind" ];
        depends = [ "/yl" "/yl/code" ];
      };
    };

  swapDevices = [
    { device = swapDevice; }
  ];
}
