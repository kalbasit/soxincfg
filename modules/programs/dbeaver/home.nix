{ lib, ... }:

let
  inherit (lib)
    mkEnableOption
    mkOption
    types
    ;
in
{
  imports = [ ./home-config.nix ];

  options.soxincfg.programs.dbeaver = {
    enable = mkEnableOption "programs.dbeaver";

    sopsFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = ''
        The sops file (binary format) holding DBeaver's
        `credentials-config.json` and `data-sources.json`. Without it they
        are not installed.
      '';
    };
  };
}
