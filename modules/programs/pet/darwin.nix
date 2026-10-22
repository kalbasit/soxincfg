{ lib, ... }:

let
  inherit (lib) mkEnableOption;
in
{
  imports = [ ];

  options.soxincfg.programs.pet.enable = mkEnableOption "pet";
}
