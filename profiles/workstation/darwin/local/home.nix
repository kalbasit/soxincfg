{ pkgs, soxincfg, ... }:

{
  imports = [
    soxincfg.nixosModules.profiles.neovim
    soxincfg.nixosModules.profiles.workstation.common
  ];

  home.packages = with pkgs; [ openssh ];
}
