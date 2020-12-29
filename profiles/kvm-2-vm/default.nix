{ ... }:

{
  # environment.persistence."/persist" = {
  #   directories = [
  #     "/var/log"
  #     "/root"
  #   ];
  #   files = [
  #     "/etc/machine-id"
  #   ];
  # };

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
    device = "/dev/sda";
  };

  fileSystems = {
    "/" = {
      fsType = "tmpfs";
    };
    "/nix" = {
      label = "nixos-nix";
      fsType = "ext4";
    };
    # "/persist" = {
    #   label = "nixos-persist";
    #   fsType = "ext4";
    #   neededForBoot = true;
    # };
    "/boot" = {
      label = "nixos-boot";
      fsType = "ext4";
    };
    "/efi" = {
      label = "nixos-efi";
      fsType = "vfat";
    };
  };
}
