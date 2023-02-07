{ config, lib, mode, options, pkgs, ... }:

with lib;
let
  cfg = config.soxincfg.services.dnsmasq;
in
{
  options.soxincfg.services.dnsmasq = {
    enable = mkEnableOption "Install and configure DNSMasq";

    blockAds = mkEnableOption "Automatically pull the blocklist to block all ads";
  };

  config = mkIf cfg.enable (mkMerge [
    (optionalAttrs (mode == "NixOS") {
      services.dnsmasq = {
        inherit (cfg) enable;

        alwaysKeepRunning = true; # do not allow the system to turn the service off
      };

      networking.networkmanager.dns = "dnsmasq";
    })

    (optionalAttrs (mode == "NixOS") (mkIf cfg.blockAds
      {
        services.dnsmasq.extraConfig = ''
          conf-file=/var/lib/dnsmasq/notracking/hosts-blocklists/domains.txt
          addn-hosts=/var/lib/dnsmasq/notracking/hosts-blocklists/hostnames.txt
        '';

        systemd.services.dnsmasq.preStart = with pkgs; ''
          if ! [[ -d /var/lib/dnsmasq/notracking/hosts-blocklists ]]; then
            mkdir -p /var/lib/dnsmasq/notracking
            ${git}/bin/git clone https://github.com/notracking/hosts-blocklists.git /var/lib/dnsmasq/notracking/hosts-blocklists
            chown -R dnsmasq /var/lib/dnsmasq/notracking
          fi
        '';

        systemd.services.update-notracking-hosts-blocklists = {
          description = "Update the notracking hosts blocklists";
          after = [ "dnsmasq.service" ];
          serviceConfig = {
            ExecStart = with pkgs; writeScript "update-notracking-hosts-blocklists.sh" ''
              #!${runtimeShell}
              set -euo pipefail
              cd /var/lib/dnsmasq/notracking/hosts-blocklists
              ${git}/bin/git config pull.ff only
              ${git}/bin/git pull
              chown -R dnsmasq /var/lib/dnsmasq/notracking
              systemctl reload dnsmasq.service
            '';
          };
        };

        systemd.timers.update-notracking-hosts-blocklists = {
          description = "Update the notracking hosts blocklists once a day";
          wantedBy = [ "timers.target" ];
          timerConfig = {
            Unit = "update-notracking-hosts-blocklists.service";
            OnCalendar = "*-*-* 23:00:00";
            OnBootSec = "15min";
          };
        };
      }))
  ]);
}
