{
  soxincfg,
  ...
}:

{
  imports = [
    soxincfg.nixosModules.profiles.pve-miniserver

    ./hardware-configuration.nix
  ];

  system.stateVersion = "25.05";
}
