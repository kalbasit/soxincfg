{ lib, ... }:

let
  inherit (lib) optionals;
in
{
  imports = [ ./home-config.nix ];
}
