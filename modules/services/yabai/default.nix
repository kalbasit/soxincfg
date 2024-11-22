{ lib, mode, ... }:

let
  inherit (lib) mkEnableOption optionals;
in
{
  imports =
    [ ]
    ++ optionals (mode == "home-manager") [ ./home-manager.nix ]
    ++ optionals (mode == "nix-darwin") [ ./darwin.nix ];

  options.soxincfg.services.yabai.enable = mkEnableOption "Install and configure Yabai";
}
