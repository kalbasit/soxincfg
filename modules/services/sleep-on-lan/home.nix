{
  lib,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkOption
    optionals
    types
    ;
in
{
  imports = [ ];

  options.soxincfg.services.sleep-on-lan = {
    enable = mkEnableOption "services.sleep-on-lan";

    sopsFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = ''
        The sops file holding `etc_sol_json`, sleep-on-lan's configuration
        (/etc/sol.json). Without it the configuration is not installed.
      '';
    };
  };
}
