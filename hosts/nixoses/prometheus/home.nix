# home-manager configuration for user `yl`
{ soxincfg }:

{ ... }:

{
  imports = [
    soxincfg.nixosModules.profiles.myself
    soxincfg.nixosModules.profiles.server
  ];
}
