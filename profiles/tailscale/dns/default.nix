{
  lib,
  mode,
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
  ++ optionals (mode == "NixOS") [ ./nixos.nix ];
}
