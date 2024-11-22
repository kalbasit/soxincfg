{
  config,
  lib,
  mode,
  ...
}:

let
  inherit (lib) mkEnableOption optionals;

  cfg = config.soxincfg.services.sleep-on-lan;
in
{
  imports = [ ] ++ optionals (mode == "NixOS") [ ./nixos.nix ];

  options.soxincfg.services.sleep-on-lan = {
    enable = mkEnableOption "services.sleep-on-lan";
  };
}
