{
  config,
  lib,
  mode,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.soxincfg.services.nextcloud;
in
{
  options.soxincfg.services.nextcloud.enable = mkEnableOption "Install and configure nextcloud";

  config = mkIf cfg.enable (mkMerge [
    (optionalAttrs (mode == "NixOS") {
      networking.firewall = {
        enable = mkForce false; # TODO
        allowedTCPPorts = [
          80
          443
        ];
      };

      services = {
        nextcloud = {
          autoUpdateApps.enable = true;
          enable = true;

          hostName = "nextcloud.nasreddine.com";
          https = true;
          config = {
            adminuser = "admin";
            adminpassFile = "/run/secrets/nextcloud_adminpass_file";
            dbhost = "/run/postgresql";
            dbtype = "pgsql";
            defaultPhoneRegion = "US";
            overwriteProtocol = "https";
          };

          package = pkgs.nextcloud21;
        };

        nginx.virtualHosts."nextcloud.nasreddine.com" = {
          forceSSL = true;
          sslCertificateKey = "/run/secrets/nextcloud_nasreddine_com_key";
          sslCertificate = ./nextcloud.nasreddine.com.crt;
        };

        postgresql = {
          enable = true;
          package = pkgs.postgresql_12;
          ensureDatabases = singleton "nextcloud";
          ensureUsers = [
            {
              name = "nextcloud";
              ensurePermissions = {
                "DATABASE nextcloud" = "ALL PRIVILEGES";
                "ALL TABLES IN SCHEMA public" = "ALL PRIVILEGES";
              };
            }
          ];
        };
      };

      sops.secrets = {
        nextcloud_adminpass_file = {
          sopsFile = ./secrets.sops.yaml;
          owner = config.users.users.nextcloud.name;
        };

        nextcloud_nasreddine_com_key = {
          sopsFile = ./nextcloud.nasreddine.com.key.sops;
          owner = config.users.users.nginx.name;
          format = "binary";
        };
      };

      users.users = {
        # allow nextcloud user access to sops secrets
        nextcloud.extraGroups = singleton config.users.groups.keys.name;

        # allow nginx user access to sops secrets
        nginx.extraGroups = singleton config.users.groups.keys.name;
      };
    })
  ]);
}
