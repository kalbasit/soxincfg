{ lib, mode, ... }:

let
  inherit (lib) mkEnableOption optionals;
in
{
  imports =
    [ ]
    ++ optionals (mode == "NixOS") [ ./nixos.nix ]
    ++ optionals (mode == "home-manager") [ ./home.nix ];

  options.soxincfg.programs.dbeaver = {
    enable = mkEnableOption "programs.dbeaver";
  };
}
