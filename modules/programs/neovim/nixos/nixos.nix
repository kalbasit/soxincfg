{ lib, ... }:

let
  inherit (lib) optionals;
in
{
  imports = [ ../nixos-nixos.nix ];
}
