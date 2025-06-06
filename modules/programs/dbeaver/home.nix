{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkIf;

  inherit (pkgs.hostPlatform) isDarwin;

  homePath = config.home.homeDirectory;
  sopsFile = ./credentials-config.json.sops;

  cfg = config.soxincfg.programs.dbeaver;
in
{
  config = mkIf cfg.enable {
    home.packages = [ pkgs.dbeaver-bin ];

    sops.secrets = mkIf isDarwin {
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
