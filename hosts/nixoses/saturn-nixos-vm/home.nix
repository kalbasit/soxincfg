# home-manager configuration for user `yl`
{ soxincfg }:

{
  imports = [
    soxincfg.nixosModules.profiles.myself
    soxincfg.nixosModules.profiles.personal
    soxincfg.nixosModules.profiles.workstation.nixos.vm-guest
  ];

  home.stateVersion = "24.11";
}
