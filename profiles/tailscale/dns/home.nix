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
    soxincfg.homeModules.profiles.tailscale.basicdns
  ];
}
