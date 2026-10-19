{ lib, ... }:

let
  inherit (lib) mkEnableOption optionals;
in
{
  imports = [ ];

  options.soxincfg.programs.dbeaver = {
    enable = mkEnableOption "programs.dbeaver";
  };
}
