{ lib, ... }:

let
  inherit (lib) mkEnableOption;
in
{
  imports = [ ];

  options.soxincfg.programs.zellij.enable = mkEnableOption "zellij";
}
