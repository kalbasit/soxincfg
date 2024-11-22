{ lib, mode, ... }:

let
  inherit (lib) mkEnableOption optionals;
in
{
  imports =
    [ ]
    ++ optionals (mode == "home-manager") [ ./home-manager.nix ]
    ++ optionals (mode == "nix-darwin") [ ./darwin.nix ];

  options.soxincfg.services.skhd.enable = mkEnableOption "Install and configure Skhd";
}
