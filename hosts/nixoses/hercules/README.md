# Hercules

My main workstation, a laptop with a decent i7-11800H CPU, 64G RAM and an RTX 3080 Max-Q GPU

## Install

Leaving my installation instructions to help me re-do the laptop if I needed to.

### Create the ZFS Pool

This assumes you've already created the partitions, the root partitions is
encrypted and open at /dev/mapper/cryptroot.

```bash
sudo zpool create \
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
    olympus \
    /dev/mapper/cryptroot
```

### Create the ZFS volumes

```bash
sudo zfs create -o mountpoint=none olympus/system
sudo zfs create -o mountpoint=none olympus/system/nixos
sudo zfs create -o mountpoint=legacy olympus/system/nixos/root
sudo zfs create -o mountpoint=legacy olympus/system/nixos/var
sudo zfs create -o mountpoint=legacy olympus/system/nixos/nix

sudo zfs create -o mountpoint=none olympus/user
sudo zfs create -o mountpoint=none olympus/user/yl
sudo zfs create -o mountpoint=legacy olympus/user/yl/home
sudo zfs create -o mountpoint=legacy olympus/user/yl/code
```

### Mount everything

#### Mount all ZFS volumes

```bash
sudo zfs mount -a

sudo mount -t zfs olympus/system/nixos/root /mnt

sudo mkdir -p /mnt/{var,nix}

sudo mount -t zfs olympus/system/nixos/var /mnt/var
sudo mount -t zfs olympus/system/nixos/nix /mnt/nix
```

#### Mount user's home directory (optional)

```bash
sudo mkdir -p /mnt/home/yl
sudo mount --bind /home/yl /mnt/home/yl
sudo mount --bind /home/yl/code /mnt/home/yl/code
```

#### Mount the boot/efi partition

This assumes then boot partition is labeled EFI.

```bash
sudo mkdir -p /mnt/boot
sudo mount /dev/disk/by-label/EFI /mnt/boot
```

### Install NixOS

Finally proceed with NixOS installation following the [instructions on the manual][nixos-manual-install].

## Restore bootloader

### Decrypt the drive

```bash
sudo cryptsetup luksOpen /dev/disk/by-uuid/00f72dbb-eb46-468f-b1c3-dd63adc542f0 cryptkey
sudo cryptsetup luksOpen --key-file=/dev/mapper/cryptkey /dev/disk/by-uuid/5f4422ca-eb45-4532-931b-63225c2143d5 cryptroot
```

### Import the pool

```bash
sudo zpool import olympus
sudo zfs list olympus
```

Refer to [Mount everything](#mount-everything) above to mount the everything you need.

### Download nixos-enter (optional, needed for non-nixos boot USB)

*NOTE*: This was needed because I was using ubuntu to do the restore (for the
fun of it). NixOS install disk already has nixos-enter in the PATH.

```bash
curl -LO https://github.com/NixOS/nixpkgs/raw/master/nixos/modules/installer/tools/nixos-enter.sh
```

### Enter the nixos system

```bash
sudo bash nixos-enter.sh  # on NixOS, just run: nixos-enter
```

### Reinstall bootloader

```bash
NIXOS_INSTALL_BOOTLOADER=1 /run/current-system/bin/switch-to-configuration boot
```

[nixos-manual-install]: https://nixos.org/manual/nixos/stable/#sec-installation
