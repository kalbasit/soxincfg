{
  config,
  lib,
  pkgs,
  soxincfg,
  ...
}:

{
  imports = [
    soxincfg.nixosModules.profiles.neovim.full
    soxincfg.nixosModules.profiles.workstation.common
  ];

  home.packages = [ pkgs.mosh ];

  home.activation.screenshots-directory = lib.hm.dag.entryAnywhere ''
    mkdir -p ${config.home.homeDirectory}/Pictures/Screenshots
  '';

}
