{ lib, ... }:

let
  inherit (lib) mkEnableOption optionals;
in
{
  imports =
    [ ./nixos-config.nix ];

  options.soxincfg.programs.dbeaver = {
    enable = mkEnableOption "programs.dbeaver";
  };
}
