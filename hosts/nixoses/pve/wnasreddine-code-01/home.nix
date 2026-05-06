{ soxincfg }:

{
  imports = [
    soxincfg.nixosModules.profiles.code
  ];

  home.stateVersion = "25.05";
}
