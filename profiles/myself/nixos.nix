{ lib, ... }:

let
  inherit (lib) optionals;
in
{
  imports =
    [ ./nixos-config.nix ];
}
