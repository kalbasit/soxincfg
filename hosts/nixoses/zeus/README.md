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
    -O mountpoint=none \
    rpool \
    /dev/nvme0n1p1

zfs create -o canmount=noauto rpool/nixos

zfs create -o canmount=noauto -o mountpoint=legacy rpool/nixos/root
mount -t zfs rpool/nixos/root /mnt

zfs create -o mountpoint=legacy rpool/nixos/home
mkdir /mnt/home
mount -t zfs  rpool/nixos/home /mnt/home

zfs create -o mountpoint=legacy  rpool/nixos/var
mkdir /mnt/var
mount -t zfs  rpool/nixos/var /mnt/var

zfs create -o mountpoint=legacy rpool/nixos/var/lib
mkdir /mnt/var/lib
mount -t zfs  rpool/nixos/var/lib /mnt/var/lib

zfs create -o mountpoint=legacy rpool/nixos/var/log
mkdir /mnt/var/log
mount -t zfs  rpool/nixos/var/log /mnt/var/log

zfs snapshot rpool/nixos@start

# create and mount the /boot partition, EFI

nixos-generate-config --root /mnt

nixos-install
