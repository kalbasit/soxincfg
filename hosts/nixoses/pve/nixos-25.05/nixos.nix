{
  soxincfg,
  ...
}:

{
  imports = [
    soxincfg.nixosModules.profiles.miniserver.qemu-vm-guest

    ./hardware-configuration.nix
  ];

  networking = {
    nameservers = [
      "8.8.8.8"
      "8.8.4.4"
    ];

    useDHCP = false;
  };

  system.stateVersion = "25.05";
}
