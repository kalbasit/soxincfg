{
  lib,
  ...
}:

let
  inherit (lib)
    optionals
    ;
in
{
  imports = [ ../common/nixos.nix ] ++ [ ./nixos-config.nix ];
}
