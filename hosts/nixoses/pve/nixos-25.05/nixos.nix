{
  soxincfg,
  ...
}:

{
  imports = [
    soxincfg.nixosModules.profiles.miniserver.qemu-vm-guest

    ./hardware-configuration.nix
  ];

  # Run QEMU Quest Agent
  services.qemuGuest.enable = true;

  system.stateVersion = "25.05";
}
