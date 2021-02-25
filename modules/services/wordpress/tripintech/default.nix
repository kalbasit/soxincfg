{ config, lib, mode, options, pkgs, ... }:

with lib;
let
  cfg = config.soxincfg.services.wordpress.tripintech;
in
{
  options.soxincfg.services.wordpress.tripintech = {
    enable = mkEnableOption "Serve the Trip in tech Wordpress";
  };

  config = mkIf cfg.enable (mkMerge [
    (optionalAttrs (mode == "NixOS") {
      sops.secrets.wordpress_tripintech_database_password_file = {
        sopsFile = ./secrets.sops.yaml;
      };

      services.wordpress.tripintech = {
        database = {
          name = "tripintech";
          passwordFile = "/run/secrets/wordpress_tripintech_database_password_file";
        };
      };
    })
  ]);
}
