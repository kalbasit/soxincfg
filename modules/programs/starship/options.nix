{ lib, ... }:

{
  options.soxincfg.programs.starship.enable = lib.mkEnableOption "starship prompt";
}
