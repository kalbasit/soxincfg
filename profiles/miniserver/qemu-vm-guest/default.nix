{
  lib,
  mode,
  ...
}:

let
  inherit (lib)
    optionals
    ;
in
{
  imports = [ ../common ] ++ optionals (mode == "NixOS") [ ./nixos.nix ];
}
