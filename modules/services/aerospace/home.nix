{ lib, ... }:

let
  inherit (lib) mkEnableOption optionals;
in
{
  imports = [ ];

  options.soxincfg.services.aerospace.enable = mkEnableOption "Install and configure Aerospace";
}
