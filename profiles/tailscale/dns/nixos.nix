{
  lib,
  soxincfg,
  ...
}:

let
  inherit (lib) optionals;
in
{
  imports = [
    soxincfg.nixosModules.profiles.tailscale.basicdns
  ]
  ++ [ ./nixos-config.nix ];
}
