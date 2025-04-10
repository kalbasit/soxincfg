# home-manager configuration for user `yl`
{ soxincfg }:
{
  config,
  pkgs,
  home-manager,
  ...
}:

{
  imports = [
    soxincfg.nixosModules.profiles.myself
    soxincfg.nixosModules.profiles.personal
    soxincfg.nixosModules.profiles.workstation.darwin.local
  ];

  home.stateVersion = "23.05";

  sops.age.keyFile = "${config.home.homeDirectory}/.local/share/soxincfg/sops/age.key";
}
