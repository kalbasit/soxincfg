{ lib, ... }:

let
  inherit (lib) mkEnableOption;
in
{
  imports = [ ./home-config.nix ];

  options.soxincfg.programs.zellij.enable = mkEnableOption "zellij";
}
