{ lib, ... }:

let
  inherit (lib) optionals;
in
{
  imports = [ ./darwin-config.nix ];
}
