{ config, lib, mode, ... }:

let
  inherit (lib)
    optionals
    ;
in
{
  imports =
    [ ]
    ++ optionals (mode == "home-manager") [ ./home.nix ];
}
