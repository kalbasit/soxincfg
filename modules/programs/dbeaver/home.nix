{ lib, ... }:

let
  inherit (lib) mkEnableOption optionals;
in
{
  imports =
    [ ./home-config.nix ];

  options.soxincfg.programs.dbeaver = {
    enable = mkEnableOption "programs.dbeaver";
  };
}
