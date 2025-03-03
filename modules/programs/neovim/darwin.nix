{ lib, mode, ... }:

let
  inherit (lib) optionals;
in
{
  imports =
    optionals (mode == "nix-darwin") [ ./darwin-darwin.nix ]
    ++ optionals (mode == "home-manager") [ ./common-home.nix ];
}
