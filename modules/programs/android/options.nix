{ lib, ... }:

{
  options.soxincfg.programs.android.enable = lib.mkEnableOption "Enable Android";
}
