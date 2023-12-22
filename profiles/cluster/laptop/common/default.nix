{ lib, mode, ... }:

let
  inherit (lib)
    optionals
    ;
in
{
  imports =
    [ ]
    ++ optionals (mode == "NixOS") [ ./nixos.nix ];
}
