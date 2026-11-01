{ lib, ... }:

{
  options.soxincfg.programs.mosh.enable = lib.mkEnableOption "mosh, the mobile shell";
}
