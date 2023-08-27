# home-manager configuration for user `yl`
{ soxincfg }:

{ ... }:

{
  imports = [
    soxincfg.nixosModules.profiles.myself
    soxincfg.nixosModules.profiles.server
  ];

  home.stateVersion = "23.05";
}
