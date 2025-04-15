{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    mkDefault
    nameValuePair
    mergeAttrs
    mapAttrs'
    ;

  bootDevice = "/dev/disk/by-uuid/733F-28F5";
  swapDevice = "/dev/zvol/olympus/system/nixos/swap";
  windowsDevice = "/dev/disk/by-uuid/28C025C1C025965A";

  datasets = {
    # NixOS
    "/" = {
      device = "olympus/system/nixos/root";
    };
    "${config.soxincfg.settings.users.user.home}" = {
      device = "olympus/user/yl/nixos-home";
    };
    "${config.soxincfg.settings.users.user.home}/.SynologyDrive/data" = {
      device = "olympus/user/yl/synology-drive/data";
    };
    "${config.soxincfg.settings.users.user.home}/.config/Signal" = {
      device = "olympus/user/yl/nixos-signal";
    };
    "${config.soxincfg.settings.users.user.home}/SynologyDrive" = {
      device = "olympus/user/yl/synology-drive/drive";
    };
    "${config.soxincfg.settings.users.user.home}/code" = {
      device = "olympus/user/yl/code";
    };
    "/nix" = {
      device = "olympus/system/nixos/nix";
    };
    "/var" = {
      device = "olympus/system/nixos/var";
    };

    ## Arch Linux
    # Arch Linux within NixOS
    "/mnt/arch" = {
      device = "olympus/system/arch/root";
    };
    "/mnt/arch${config.soxincfg.settings.users.user.home}" = {
      device = "olympus/user/yl/arch-home";
    };
    "/mnt/arch${config.soxincfg.settings.users.user.home}/.SynologyDrive/data" = {
      device = "olympus/user/yl/synology-drive/data";
    };
    "/mnt/arch${config.soxincfg.settings.users.user.home}/.config/Signal" = {
      device = "olympus/user/yl/arch-signal";
    };
    "/mnt/arch${config.soxincfg.settings.users.user.home}/SynologyDrive" = {
      device = "olympus/user/yl/synology-drive/drive";
    };
    "/mnt/arch${config.soxincfg.settings.users.user.home}/code" = {
      device = "olympus/user/yl/code";
    };
    "/mnt/arch/nix" = {
      device = "olympus/system/arch/nix";
    };
    "/mnt/arch/var" = {
      device = "olympus/system/arch/var";
    };

    # NixOS within Arch Linux
    "/mnt/arch/mnt/nixos" = {
      device = "olympus/system/nixos/root";
    };
    "/mnt/arch/mnt/nixos${config.soxincfg.settings.users.user.home}" = {
      device = "olympus/user/yl/nixos-home";
    };
    "/mnt/arch/mnt/nixos${config.soxincfg.settings.users.user.home}/.SynologyDrive/data" = {
      device = "olympus/user/yl/synology-drive/data";
    };
    "/mnt/arch/mnt/nixos${config.soxincfg.settings.users.user.home}/.config/Signal" = {
      device = "olympus/user/yl/nixos-signal";
    };
    "/mnt/arch/mnt/nixos${config.soxincfg.settings.users.user.home}/SynologyDrive" = {
      device = "olympus/user/yl/synology-drive/drive";
    };
    "/mnt/arch/mnt/nixos${config.soxincfg.settings.users.user.home}/code" = {
      device = "olympus/user/yl/code";
    };
    "/mnt/arch/mnt/nixos/nix" = {
      device = "olympus/system/nixos/nix";
    };
    "/mnt/arch/mnt/nixos/var" = {
      device = "olympus/system/nixos/var";
    };

    ## Ubuntu
    # Ubuntu within NixOS
    "/mnt/ubuntu" = {
      device = "olympus/system/ubuntu/root";
    };
    "/mnt/ubuntu${config.soxincfg.settings.users.user.home}" = {
      device = "olympus/user/yl/ubuntu-home";
    };
    "/mnt/ubuntu${config.soxincfg.settings.users.user.home}/.SynologyDrive/data" = {
      device = "olympus/user/yl/synology-drive/data";
    };
    "/mnt/ubuntu${config.soxincfg.settings.users.user.home}/.config/Signal" = {
      device = "olympus/user/yl/ubuntu-signal";
    };
    "/mnt/ubuntu${config.soxincfg.settings.users.user.home}/SynologyDrive" = {
      device = "olympus/user/yl/synology-drive/drive";
    };
    "/mnt/ubuntu${config.soxincfg.settings.users.user.home}/code" = {
      device = "olympus/user/yl/code";
    };
    "/mnt/ubuntu/nix" = {
      device = "olympus/system/ubuntu/nix";
    };
    "/mnt/ubuntu/var" = {
      device = "olympus/system/ubuntu/var";
    };

    # NixOS within Ubuntu
    "/mnt/ubuntu/mnt/nixos" = {
      device = "olympus/system/nixos/root";
    };
    "/mnt/ubuntu/mnt/nixos${config.soxincfg.settings.users.user.home}" = {
      device = "olympus/user/yl/nixos-home";
    };
    "/mnt/ubuntu/mnt/nixos${config.soxincfg.settings.users.user.home}/.SynologyDrive/data" = {
      device = "olympus/user/yl/synology-drive/data";
    };
    "/mnt/ubuntu/mnt/nixos${config.soxincfg.settings.users.user.home}/.config/Signal" = {
      device = "olympus/user/yl/nixos-signal";
    };
    "/mnt/ubuntu/mnt/nixos${config.soxincfg.settings.users.user.home}/SynologyDrive" = {
      device = "olympus/user/yl/synology-drive/drive";
    };
    "/mnt/ubuntu/mnt/nixos${config.soxincfg.settings.users.user.home}/code" = {
      device = "olympus/user/yl/code";
    };
    "/mnt/ubuntu/mnt/nixos/nix" = {
      device = "olympus/system/nixos/nix";
    };
    "/mnt/ubuntu/mnt/nixos/var" = {
      device = "olympus/system/nixos/var";
    };
  };

  mkZFSDataSet =
    mountPoint:
    { device }:
    nameValuePair mountPoint {
      inherit device;
      fsType = "zfs";
      options = [ "relatime" ];
    };

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

  toFSEntry =
    export:
    nameValuePair "/nas/${export}" {
      device = "192.168.50.2:/volume1/${export}";
      fsType = "nfs";
    };

  nfsFSEntries = builtins.listToAttrs (map toFSEntry exports);
in
{
  boot = {
    # Topology config for routing audio/microphone on Razer laptops
    # copied from https://github.com/eureka-cpu/dotfiles/blob/tensorbook/nixos/configuration.nix
    extraModprobeConfig = ''
      options snd-sof-pci tplg_filename=sof-hda-generic-2ch-pdm1.tplg
    '';

    # configure kernel and modules
    initrd.availableKernelModules = [
      "xhci_pci"
      "thunderbolt"
      "vmd"
      "nvme"
      "usbhid"
      "usb_storage"
      "sd_mod"
      "sdhci_pci"
    ];
    kernelModules = [ "kvm-intel" ];

    # configure boot loader
    loader.efi.canTouchEfiVariables = true;
    loader.systemd-boot = {
      editor = false;
      enable = true;
      extraEntries = {
        "archlinux.conf" = ''
          title Arch Linux
          sort-key 30-arch
          version Main
          linux /EFI/arch/vmlinuz-linux
          initrd /EFI/arch/initramfs-linux.img
          options spl.spl_hostid=0x007f0200 cryptdevice=/dev/disk/by-uuid/809f49a2-0edb-49ac-aab6-fc0c77565e74:cryptroot zfs=olympus/system/arch/root rw
          machine-id eb9cb30c8e1d473e91ef3c792d4af65c
        '';

        "archlinux-fallback.conf" = ''
          title Arch Linux
          sort-key 30-arch
          version Fallback
          linux /EFI/arch/vmlinuz-linux
          initrd /EFI/arch/initramfs-linux-fallback.img
          options spl.spl_hostid=0x007f0200 cryptdevice=/dev/disk/by-uuid/809f49a2-0edb-49ac-aab6-fc0c77565e74:cryptroot zfs=olympus/system/arch/root rw
          machine-id eb9cb30c8e1d473e91ef3c792d4af65c
        '';

        "qubes-os.conf" = ''
          title Qubes OS
          sort-key 10-qubes-os
          linux /EFI/qubes/grubx64.efi
        '';

        "ubuntu.conf" = ''
          title Ubuntu
          sort-key 40-ubuntu
          version Main
          linux /EFI/ubuntu/vmlinuz
          initrd /EFI/ubuntu/initrd.img
          options spl.spl_hostid=0x007f0200 root=ZFS=olympus/system/ubuntu/root rw quiet splash
          machine-id eb9cb30c8e1d473e91ef3c792d4af65c
        '';
      };
      configurationLimit = 3;
      sortKey = "20-nixos";
    };

    initrd.luks.devices = {
      cryptkey = {
        device = "/dev/disk/by-uuid/00f72dbb-eb46-468f-b1c3-dd63adc542f0";
      };
      cryptroot = {
        device = "/dev/disk/by-uuid/809f49a2-0edb-49ac-aab6-fc0c77565e74";
        keyFile = "/dev/mapper/cryptkey";
      };
    };
  };

  hardware = {
    # Common firmware, i.e. for wifi cards
    enableRedistributableFirmware = true;

    cpu.intel.updateMicrocode = mkDefault config.hardware.enableRedistributableFirmware;

    # nvidia-drm.modeset=1 is required for some wayland compositors, e.g. sway
    nvidia.modesetting.enable = true;
  };

  # ZFS requires a networking hostId
  networking.hostId = "007f0200";

  # enable focusrite Gen3 support.
  soxin.hardware.sound.focusRiteGen3Support = true;

  nix.settings.max-jobs = 12;

  powerManagement.cpuFreqGovernor = "powersave";

  services.xserver.videoDrivers = [ "nvidia" ];

  console.font = "Lat2-Terminus16";

  fileSystems = mergeAttrs (mergeAttrs nfsFSEntries (mapAttrs' mkZFSDataSet datasets)) {
    # Boot device
    "/boot" = {
      device = bootDevice;
      fsType = "vfat";
      options = [
        "fmask=0022"
        "dmask=0022"
      ];
    };

    # Arch non-zfs mounts
    "/mnt/arch/boot" = {
      device = bootDevice;
      fsType = "vfat";
      options = [
        "fmask=0022"
        "dmask=0022"
      ];
    };
    "/mnt/arch/dev" = {
      device = "/dev";
      options = [ "bind" ];
    };
    "/mnt/arch/dev/pts" = {
      device = "/dev/pts";
      options = [ "bind" ];
    };
    "/mnt/arch/proc" = {
      device = "proc";
      fsType = "proc";
    };
    "/mnt/arch/sys" = {
      device = "sys";
      fsType = "sysfs";
    };

    # Ubuntu non-zfs device
    # TODO: Figure out how to configure Ubuntu where to put kernel instead of the /boot-real /boot hack
    "/mnt/ubuntu/boot" = {
      device = "/mnt/ubuntu/boot-real/EFI/ubuntu";
      options = [ "bind" ];
    };
    "/mnt/ubuntu/boot-real" = {
      device = bootDevice;
      fsType = "vfat";
      options = [
        "fmask=0022"
        "dmask=0022"
      ];
    };
    "/mnt/ubuntu/dev" = {
      device = "/dev";
      options = [ "bind" ];
    };
    "/mnt/ubuntu/dev/pts" = {
      device = "/dev/pts";
      options = [ "bind" ];
    };
    "/mnt/ubuntu/proc" = {
      device = "proc";
      fsType = "proc";
    };
    "/mnt/ubuntu/sys" = {
      device = "sys";
      fsType = "sysfs";
    };

    # Windows
    "/mnt/windows" = {
      device = windowsDevice;
      fsType = "ntfs";
      options = [
        "gid=${builtins.toString config.users.groups."${config.users.users.yl.group}".gid}"
        "uid=${builtins.toString config.users.users.yl.uid}"
      ];
    };
  };

  swapDevices = [ { device = swapDevice; } ];
}
