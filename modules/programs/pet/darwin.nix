{ lib, ... }:

let
  inherit (lib) mkEnableOption optionals;
in
{
  imports = [ ];

  options.soxincfg.programs.pet.enable = mkEnableOption "pet";
}
