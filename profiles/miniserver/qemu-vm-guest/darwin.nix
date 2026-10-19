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
  imports = [ ../common/darwin.nix ];
}
