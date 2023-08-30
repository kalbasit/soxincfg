{ soxincfg, lib, mode, ... }:

let
  inherit (lib)
    mkDefault
    mkEnableOption
    mkIf
    optionalAttrs
    optionals
    ;
in
{
  imports =
    [ ]
    ++ optionals (mode == "NixOS") [ ./nixos.nix ]
    ++ optionals (mode == "nix-darwin") [ ./darwin.nix ]
    ++ optionals (mode == "home-manager") [ ./home.nix ];
}
