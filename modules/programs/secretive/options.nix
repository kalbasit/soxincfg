{ lib, ... }:

{
  options.soxincfg.programs.secretive = {
    enable = lib.mkEnableOption "the secretive SSH agent";
  };
}
