{ config, lib, ... }:

let
  inherit (lib) mkIf;

  homePath = config.users.users.yl.home;
  owner = config.users.users.yl.name;
  sopsFile = ./credentials-config.json.sops;

  cfg = config.soxincfg.programs.dbeaver;
in
{
  config = mkIf cfg.enable {
    sops.secrets = {
      credentials-config-json = {
        inherit sopsFile owner;
        format = "binary";
        path = "${homePath}/.local/share/DBeaverData/workspace6/General/.dbeaver/credentials-config.json";
      };

      data-sources-json = {
        inherit sopsFile owner;
        format = "binary";
        path = "${homePath}/.local/share/DBeaverData/workspace6/General/.dbeaver/data-sources.json";
      };
    };
  };
}
