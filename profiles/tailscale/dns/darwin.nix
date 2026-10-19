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
    soxincfg.darwinModules.profiles.tailscale.basicdns
  ];
}
