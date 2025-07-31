{
  config,
  lib,
  soxincfg,
  ...
}:

{
  imports = [
    soxincfg.nixosModules.profiles.neovim.full
    soxincfg.nixosModules.profiles.workstation.common
  ];

  home.activation.screenshots-directory = lib.hm.dag.entryAnywhere ''
    mkdir -p ${config.home.homeDirectory}/Pictures/Screenshots
  '';

}
