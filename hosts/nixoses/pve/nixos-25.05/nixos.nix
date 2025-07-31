{
  soxincfg,
  ...
}:

{
  imports = [
    soxincfg.nixosModules.profiles.miniserver.qemu-vm-guest

    ./hardware-configuration.nix
  ];

  system.stateVersion = "25.05";
}
