{ lib, mode, ... }:

let
  inherit (lib) optionals;
in
{
  imports =
    optionals (mode == "NixOS") [ ./nixos-nixos.nix ]
    ++ optionals (mode == "home-manager") [ ./common-home.nix ];
}
