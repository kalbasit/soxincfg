{ lib, ... }:

let
  inherit (lib) optionals;
in
{
  imports = [ ../common-home.nix ];
}
