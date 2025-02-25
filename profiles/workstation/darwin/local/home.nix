{ soxincfg, ... }:

{
  imports = [
    soxincfg.nixosModules.profiles.neovim
    soxincfg.nixosModules.profiles.workstation.common
  ];
}
