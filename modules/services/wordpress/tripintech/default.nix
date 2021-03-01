{ config, lib, mode, options, pkgs, ... }:

with lib;
let
  cfg = config.soxincfg.services.wordpress.tripintech;
in
{
  options.soxincfg.services.wordpress.tripintech = {
    enable = mkEnableOption "Serve the Trip in tech Wordpress";

    openFirewall = mkEnableOption "open TCP ports 80 and 443";
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

      networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [ 80 443 ];
    })
  ]);
}
