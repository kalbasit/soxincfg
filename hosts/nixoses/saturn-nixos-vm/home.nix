# home-manager configuration for user `yl`
{ soxincfg }:

{
  imports = [
    soxincfg.nixosModules.profiles.myself
    soxincfg.nixosModules.profiles.personal
    # soxincfg.nixosModules.profiles.workstation.nixos.local
  ];

  home.stateVersion = "24.11";
}
