# home-manager configuration for user `wnasreddine`
{ soxincfg }:

{
  imports = [
    soxincfg.nixosModules.profiles.wsl-gaming
  ];

  home.stateVersion = "26.05";
}
