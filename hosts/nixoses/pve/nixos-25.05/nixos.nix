{
  soxincfg,
  ...
}:

{
  imports = [
    soxincfg.nixosModules.profiles.miniserver

    ./hardware-configuration.nix
  ];

  system.stateVersion = "25.05";
}
