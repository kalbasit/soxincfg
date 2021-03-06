{ config, lib, mode, options, pkgs, ... }:

with lib;
let
  cfg = config.soxincfg.services.wordpress.tripintech;
in
{
  options.soxincfg.services.wordpress.tripintech = {
    enable = mkEnableOption "Serve the Trip in tech Wordpress";

    openFirewall = mkEnableOption "open TCP ports 80 and 443";

    enableDevTLS = mkEnableOption "enable dev.tripin.tech domain with TLS self-signed";
  };

  config = mkIf cfg.enable (mkMerge [
    (optionalAttrs (mode == "NixOS") {
      sops.secrets.wordpress_tripintech_database_password_file = {
        sopsFile = ./secrets.sops.yaml;
      };

      sops.secrets.dev-tripin-tech = mkIf cfg.enableDevTLS {
        format = "binary";
        sopsFile = ./dev.tripin.tech.key.sops;
        owner = config.systemd.services.httpd.serviceConfig.User;
      };

      services.wordpress.tripintech = {
        database = {
          name = "tripintech";
          passwordFile = "/run/secrets/wordpress_tripintech_database_password_file";
        };

        plugins =
          let
            yoast_seo = pkgs.stdenv.mkDerivation rec {
              pname = "wordpress-seo";
              version = "15.9.1";

              src = pkgs.fetchurl {
                url = "https://downloads.wordpress.org/plugin/${pname}.${version}.zip";
                sha256 = "sha256-rdRE6UuuOTefI0L6WFbnxzT/sORAMPeaF/j+jSqxQUQ=";
              };

              buildInputs = [ pkgs.unzip ];
              installPhase = "mkdir -p $out; cp -R * $out/";
            };
          in
          [ yoast_seo ];

        virtualHost = mkMerge [
          { adminAddr = "wael.nasreddine@gmail.com"; }


          (mkIf cfg.enableDevTLS {
            hostName = "dev.tripin.tech";
            forceSSL = true;

            sslServerKey = "/run/secrets/dev-tripin-tech";
            sslServerChain = ./ca-nasreddine.com.crt;
            sslServerCert = ./dev.tripin.tech.crt;
          })
        ];
      };

      networking.extraHosts = mkIf cfg.enableDevTLS "127.0.0.1 dev.tripin.tech";
      networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [ 80 443 ];
      systemd.services.httpd = mkIf cfg.enableDevTLS {
        serviceConfig.SupplementaryGroups = [ config.users.groups.keys.name ];
      };
    })
  ]);
}
