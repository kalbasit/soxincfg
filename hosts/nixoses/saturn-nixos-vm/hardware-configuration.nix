{
  lib,
  modulesPath,
  ...
}:

{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  boot = {
    loader.efi.canTouchEfiVariables = true;
    loader.systemd-boot = {
      enable = true;
      configurationLimit = 3;
    };

    initrd.availableKernelModules = [
      "xhci_pci"
      "sr_mod"
    ];
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/cd297986-6975-4e70-8e58-aa24c4605ef6";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/A457-76B5";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/79e28b78-e070-4228-b4b2-a8e91f782e8a"; }
  ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp0s1.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
}
