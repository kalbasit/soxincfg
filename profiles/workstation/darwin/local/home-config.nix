{
  config,
  lib,
  pkgs,
  soxincfg,
  ...
}:

{
  imports = [
    soxincfg.homeModules.profiles.neovim.full
    soxincfg.homeModules.profiles.workstation.common
  ];

  home.packages = [ pkgs.mosh ];

  home.activation.screenshots-directory = lib.hm.dag.entryAnywhere ''
    mkdir -p ${config.home.homeDirectory}/Pictures/Screenshots
  '';

}
