# home-manager configuration for user `yl`
{ soxincfg }:

{
  imports = [
    soxincfg.nixosModules.profiles.myself
    soxincfg.nixosModules.profiles.miniserver.qemu-vm-guest
    soxincfg.nixosModules.profiles.server
  ];

  home.stateVersion = "24.11";
}
