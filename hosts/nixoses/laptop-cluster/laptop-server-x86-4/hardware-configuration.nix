# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{
  config,
  lib,
  modulesPath,
  ...
}:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot = {
    # Use the systemd-boot EFI boot loader.
    loader.efi.canTouchEfiVariables = true;
    loader.systemd-boot = {
      configurationLimit = 2;
      enable = true;
    };

    initrd.availableKernelModules = [
      "xhci_pci"
      "ahci"
      "usbhid"
      "usb_storage"
      "sd_mod"
    ];
    initrd.kernelModules = [ ];
    kernelModules = [
      "kvm-intel"
      "wl"
    ];
    extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/f7a093c5-55e8-4601-b8a6-0f7900da4281";
      fsType = "ext4";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/8A36-00B0";
      fsType = "vfat";
    };
  };

  swapDevices = [ ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
