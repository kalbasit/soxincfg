{ config, lib, pkgs, ... }:

let
  inherit (lib)
    mkIf
    ;

  inherit (pkgs.hostPlatform)
    isDarwin
    ;

  yl_home = config.home.homeDirectory;
  sopsFile = ./credentials-config.json.sops;

  cfg = config.soxincfg.programs.dbeaver;
in
{
  config = mkIf cfg.enable {
    home.packages = [ pkgs.dbeaver-bin ];

    sops.age = mkIf isDarwin {
      generateKey = true;
      keyFile = "${yl_home}/.local/share/soxincfg/sops/age.key";
    };

    sops.secrets = mkIf isDarwin {
      credentials-config-json = {
        inherit sopsFile;
        format = "binary";
        path = "${yl_home}/.local/share/DBeaverData/workspace6/General/.dbeaver/credentials-config.json";
      };

      data-sources-json = {
        inherit sopsFile;
        format = "binary";
        path = "${yl_home}/.local/share/DBeaverData/workspace6/General/.dbeaver/data-sources.json";
      };
    };
  };
}

