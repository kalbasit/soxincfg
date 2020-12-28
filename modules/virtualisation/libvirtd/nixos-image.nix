{ soxincfg, pkgs, modulesPath, system, ... }:
let
  config = (import "${modulesPath}/../lib/eval-config.nix" {
    inherit system;
    modules = [
      {
        users = {
          mutableUsers = false;
          users.root = {
            hashedPassword = "$6$0bx5eAEsHJRxkD8.$gJ7sdkOOJRf4QCHWLGDUtAmjHV/gJxPQpyCEtHubWocHh9O7pWy10Frkm1Ch8P0/m8UTUg.Oxp.MB3YSQxFXu1";
            openssh.authorizedKeys.keys = with soxincfg.vars.users; yl.sshKeys;
          };
        };
        services.openssh = {
          enable = true;
          passwordAuthentication = false;
          extraConfig = "StrictModes no";
        };

        boot.initrd.availableKernelModules = [
          "xhci_pci"
          "ehci_pci"
          "ahci"
          "usbhid"
          "usb_storage"
          "sd_mod"
          "virtio_balloon"
          "virtio_blk"
          "virtio_pci"
          "virtio_ring"
        ];

        boot.loader.grub = {
          enable = true;
          version = 2;
          device = "/dev/vda";
        };

        fileSystems = {
          "/" = {
            fsType = "tmpfs";
          };
          "/nix" = {
            label = "nixos-nix";
            fsType = "ext4";
          };
          "/boot" = {
            label = "nixos-boot";
            fsType = "ext4";
          };
          "/efi" = {
            label = "nixos-efi";
            fsType = "vfat";
          };
        };

        # We want our template image to be as small as possible, but the deployed
        # image should be able to beof any size. Hence we resize on the first boot
        systemd.services.resize-main-fs = {
          wantedBy = [ "multi-user.target" ];
          serviceConfig.Type = "oneshot";
          script = ''
            # Resize main partition to fill the whole disk
            echo ", +" | ${pkgs.utillinux}/bin/sfdisk /dev/sda --no-reread -N 4
            echo ", +" | ${pkgs.utillinux}/bin/sfdisk /dev/sdb --no-reread
            ${pkgs.parted}/bin/partprobe
          '';
        };
      }
    ];
  }).config;

in
pkgs.vmTools.runInLinuxVM (
  pkgs.runCommand "libvirt-guest-nixos-base-image"
    {
      memSize = 768;
      preVM = ''
        diskImage=image.qcow2
        ${pkgs.vmTools.qemu}/bin/qemu-img create -f qcow2 $diskImage 5G
        mv closure xchg/
      '';
      postVM = ''
        echo compressing VM image...
        ${pkgs.vmTools.qemu}/bin/qemu-img convert -c $diskImage -O qcow2 $out/image.qcow2
      '';

      buildInputs = with pkgs; [ utillinux perl gptfdisk zfs e2fsprogs dosfstools ];
      exportReferencesGraph = [ "closure" config.system.build.toplevel ];
    } ''
    echo creating partitions...
    # Default disk for QEMU
    DISK=/dev/vda

    # Partition 1 will be the boot partition, needed for legacy (BIOS) boot
    sgdisk -a1 -n1:24K:+1000K -t1:EF02 $DISK
    # Partition 2 will be for UEFI booting (for future use)
    sgdisk     -n2:1M:+512M   -t2:EF00 $DISK
    # Partition 3 will be for the /boot partition
    sgdisk     -n3:0:+1G      -t3:BF01 $DISK
    # Partition 4 will be the main partition, using up the rest of the disk
    sgdisk     -n4:0:0        -t4:BF01 $DISK

    # Boot partitions
    mkfs.vfat -n nixos-efi "$DISK"2
    mkfs.ext4 -L nixos-boot "$DISK"3
    mkfs.ext4 -L nixos-nix "$DISK"4

    echo mounting partitions...
    # Mount the previously created partitions
    mkdir -p /mnt/{boot,efi,nix}
    mount "$DISK"3 /mnt/boot
    mount "$DISK"2 /mnt/efi
    mount "$DISK"4 /mnt/nix

    for dir in dev proc sys; do
      mkdir /mnt/$dir
      mount --bind /$dir /mnt/$dir
    done

    storePaths=$(perl ${pkgs.pathsFromGraph} /tmp/xchg/closure)
    echo filling Nix store...
    mkdir -p /mnt/nix/store
    set -f
    cp -prd $storePaths /mnt/nix/store
    # The permissions will be set up incorrectly if the host machine is not
    # running NixOS
    chown -R 0:30000 /mnt/nix/store

    mkdir -p /mnt/etc/nix
    echo 'build-users-group = ' > /mnt/etc/nix/nix.conf

    # Ensures tools requiring /etc/passwd will work (e.g. nix)
    if [ ! -e /mnt/etc/passwd ]; then
      echo "root:x:0:0:System administrator:/root:/bin/sh" > /mnt/etc/passwd
    fi

    # Register the paths in the Nix database.
    printRegistration=1 perl ${pkgs.pathsFromGraph} /tmp/xchg/closure | \
        chroot /mnt ${config.nix.package.out}/bin/nix-store --load-db

    # Create the system profile to allow nixos-rebuild to work.
    chroot /mnt ${config.nix.package.out}/bin/nix-env \
        -p /nix/var/nix/profiles/system --set ${config.system.build.toplevel}

    # `nixos-rebuild' requires an /etc/NIXOS.
    mkdir -p /mnt/etc/nixos
    touch /mnt/etc/NIXOS

    # `switch-to-configuration' requires a /bin/sh
    mkdir -p /mnt/bin
    ln -s ${config.system.build.binsh}/bin/sh /mnt/bin/sh

    echo installing GRUB...
    # Generate the GRUB menu.
    chroot /mnt ${config.system.build.toplevel}/activate
    chroot /mnt ${config.system.build.toplevel}/bin/switch-to-configuration boot
  '')
