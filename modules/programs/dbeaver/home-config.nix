{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkIf;

  inherit (pkgs.stdenv.hostPlatform) isDarwin;

  homePath = config.home.homeDirectory;
  inherit (cfg) sopsFile;

  cfg = config.soxincfg.programs.dbeaver;
in
{
  config = mkIf cfg.enable {
    home.packages = [ pkgs.dbeaver-bin ];

    sops.secrets = mkIf (isDarwin && sopsFile != null) {
      credentials-config-json = {
        inherit sopsFile;
        format = "binary";
        path = "${homePath}/.local/share/DBeaverData/workspace6/General/.dbeaver/credentials-config.json";
      };

      data-sources-json = {
        inherit sopsFile;
        format = "binary";
        path = "${homePath}/.local/share/DBeaverData/workspace6/General/.dbeaver/data-sources.json";
      };
    };
  };
}
