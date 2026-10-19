{ lib, ... }:

let
  inherit (lib) mkEnableOption optionals;
in
{
  imports = [ ./darwin-config.nix ];

  options.soxincfg.services.aerospace.enable = mkEnableOption "Install and configure Aerospace";
}
