# Installation

Leaving the raw notes of my installation session of this OS.

Following https://openzfs.github.io/openzfs-docs/Getting%20Started/NixOS/Root%20on%20ZFS/3-system-configuration.html

```bash
zpool create \
    -o ashift=13 \
    -o autotrim=on \
    -O acltype=posixacl \
    -O canmount=off \
    -O mountpoint=none \
    -O compression=lz4 \
    -O dnodesize=auto \
    -O normalization=formD \
    -O relatime=on \
    -O xattr=sa \
    olympus /dev/mapper/cryptroot

zfs create -o mountpoint=none olympus/system
zfs create -o mountpoint=legacy olympus/system/nixos
zfs create -o mountpoint=legacy olympus/system/nixos/root
zfs create -o mountpoint=legacy olympus/system/nixos/var
zfs create -o mountpoint=legacy olympus/system/nixos/nix

zfs create -o mountpoint=none olympus/user
zfs create -o mountpoint=none olympus/user/yl
zfs create -o mountpoint=/yl olympus/user/yl/home
zfs create -o mountpoint=/yl/code olympus/user/yl/code

mount -t zfs olympus/system/nixos/root /mnt
mkdir /mnt/{boot,var,nix}
mount /dev/nvme0n1p1 /mnt/boot
mount -t zfs olympus/system/nixos/var /mnt/var
mount -t zfs olympus/system/nixos/nix /mnt/nix
```

# Restore bootloader

I had to reinstall the bootloader, leaving my raw notes of how I restored bootloader

```bash
# open the devices
sudo cryptsetup luksOpen /dev/disk/by-uuid/f6d83931-7313-490f-90b9-f337f7663015 cryptkey
sudo cryptsetup luksOpen --key-file=/dev/mapper/cryptkey /dev/disk/by-uuid/c27c971e-8ba9-42c3-b75a-e89ccdc2e701 cryptroot0
sudo cryptsetup luksOpen --key-file=/dev/mapper/cryptkey /dev/disk/by-uuid/127feb77-bf29-4b76-be64-cf1c7fafaeea cryptroot1

# import the pool
sudo zpool import -f rpool

# confirm pool is imported
zfs list

# mount all ZFS filesystems
sudo mount -t zfs rpool/nixos/root /mnt/
sudo mount -t zfs rpool/nixos/home /mnt/home
sudo mount -t zfs rpool/nixos/var /mnt/var
sudo mount -t zfs rpool/nixos/var/lib /mnt/var/lib
sudo mount -t zfs rpool/nixos/var/log /mnt/var/log
sudo mount -t zfs rpool/nixos/yl /mnt/yl
sudo mount -t zfs rpool/nixos/yl/code /mnt/yl/code

# mount boot
sudo mount /dev/disk/by-uuid/E1F2-2DEC /mnt/boot

# download nixos-enter
# NOTE: This was needed because I was using ubuntu to do the restore (for the fun of it). NixOS install disk already has nixos-enter in the PATH.
curl -LO https://github.com/NixOS/nixpkgs/raw/master/nixos/modules/installer/tools/nixos-enter.sh

# Enter the nixos system
sudo bash nixos-enter.sh  # on NixOS, just run: nixos-enter

# install bootloader
NIXOS_INSTALL_BOOTLOADER=1 /run/current-system/bin/switch-to-configuration boot
```
