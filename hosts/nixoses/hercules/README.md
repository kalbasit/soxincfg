Following https://openzfs.github.io/openzfs-docs/Getting%20Started/NixOS/Root%20on%20ZFS/3-system-configuration.html

```
zpool create \
    -o ashift=12 \
    -o autotrim=on \
    -R /mnt \
    -O acltype=posixacl \
    -O canmount=off \
    -O compression=zstd \
    -O dnodesize=auto \
    -O normalization=formD \
    -O relatime=on \
    -O xattr=sa \
    -O mountpoint=/ \
    rpool \
    raidz1 \
    /dev/mapper/cryptroot0 \
    /dev/mapper/cryptroot1


zfs create -o mountpoint=legacy     rpool/nixos/root
mount -t zfs rpool/nixos/root /mnt/

zfs create -o mountpoint=legacy rpool/nixos/home
mkdir /mnt/home
mount -t zfs  rpool/nixos/home /mnt/home

zfs create -o mountpoint=legacy rpool/nixos/yl
mkdir /mnt/yl
mount -t zfs  rpool/nixos/yl /mnt/yl

zfs create -o mountpoint=legacy rpool/nixos/yl/code
mkdir /mnt/yl/code
mount -t zfs  rpool/nixos/yl/code /mnt/yl/code

zfs create -o mountpoint=legacy  rpool/nixos/var
zfs create -o mountpoint=legacy rpool/nixos/var/lib
zfs create -o mountpoint=legacy rpool/nixos/var/log
zfs create -o mountpoint=legacy rpool/nixos/empty
zfs snapshot rpool/nixos/empty@start
```
