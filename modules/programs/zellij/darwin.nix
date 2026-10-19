{ lib, ... }:

let
  inherit (lib) mkEnableOption optionals;
in
{
  imports = [ ];

  options.soxincfg.programs.zellij.enable = mkEnableOption "zellij";
}
