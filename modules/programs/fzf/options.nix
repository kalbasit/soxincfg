{ lib, ... }:

{
  options.soxincfg.programs.fzf.enable = lib.mkEnableOption "programs.fzf";
}
