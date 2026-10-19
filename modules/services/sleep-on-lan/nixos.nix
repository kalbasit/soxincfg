{
  lib,
  ...
}:

let
  inherit (lib) mkEnableOption optionals;
in
{
  imports = [ ./nixos-config.nix ];

  options.soxincfg.services.sleep-on-lan = {
    enable = mkEnableOption "services.sleep-on-lan";
  };
}
