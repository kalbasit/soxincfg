{ config, lib, mode, options, pkgs, ... }:

with lib;
let
  cfg = config.soxincfg.services.wordpress.tripintech;

  buildPluginOrTheme = with pkgs; pname: version: src: stdenv.mkDerivation {
    inherit pname version src;

    buildInputs = [ pkgs.unzip ];
    installPhase = "mkdir -p $out; cp -R * $out/";
  };

  buildPlugin = with pkgs; pname: version: sha256: buildPluginOrTheme pname version (fetchurl {
    inherit sha256;
    url = "https://downloads.wordpress.org/plugin/${pname}.${version}.zip";
  });

  buildTheme = with pkgs; pname: version: sha256: buildPluginOrTheme pname version (fetchurl {
    inherit sha256;
    url = "https://downloads.wordpress.org/theme/${pname}.${version}.zip";
  });
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
          [
            # Yoast SEO
            (buildPlugin "wordpress-seo" "15.9.1" "sha256-rdRE6UuuOTefI0L6WFbnxzT/sORAMPeaF/j+jSqxQUQ=")
          ];

        themes =
          [
            (buildTheme "hestia" "3.0.13" "sha256-Zue06cmvGX7uzqBu6OHnvwBb0NghoFqSZTk/HAJOheA=")
          ];

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
