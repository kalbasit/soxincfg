{
  lib,
  ...
}:

{
  imports = [ ../common/nixos.nix ] ++ [ ./nixos-config.nix ];
}
