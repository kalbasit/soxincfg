{
  mode,
  config,
  pkgs,
  lib,
  ...
}:

with lib;
let
  cfg = config.soxincfg.settings.networking.nextdns;
in
{
  options = {
    soxincfg.settings.networking.nextdns = {
      enable = mkEnableOption ''
        Whether to enable nextdns.
      '';
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (optionalAttrs (mode == "NixOS") {
      networking.networkmanager.dns = "systemd-resolved";

      # Set my own nextdns endpoints.
      networking.nameservers = [
        "45.90.28.0#96893a.dns.nextdns.io"
        "45.90.30.0#96893a.dns.nextdns.io"
        "2a07:a8c0::#96893a.dns.nextdns.io"
        "2a07:a8c1::#96893a.dns.nextdns.io"
      ];

      services.resolved = {
        enable = true;
        extraConfig = ''
          DNSOverTLS=yes
        '';
      };
    })
  ]);
}
