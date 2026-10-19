{
  lib,
  ...
}:

let
  inherit (lib) mkEnableOption optionals;
in
{
  imports = [ ];

  options.soxincfg.services.sleep-on-lan = {
    enable = mkEnableOption "services.sleep-on-lan";
  };
}
