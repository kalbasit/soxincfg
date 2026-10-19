{ lib, ... }:

let
  inherit (lib) optionals;
in
{
  imports = [ ../darwin-darwin.nix ];
}
