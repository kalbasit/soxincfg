{ config, lib, pkgs, mode, ... }:

with lib;

let
  cfg = config.soxincfg.services.twingate;
in
{

  options.soxincfg.services.twingate = {
    enable = mkEnableOption "Twingate Client daemon";
  };

  config = mkIf cfg.enable (mkMerge [
    (optionalAttrs (mode == "NixOS") {
      networking.firewall.checkReversePath = lib.mkDefault false;
      networking.networkmanager.enable = true;

      environment.systemPackages = [ pkgs.twingate ]; # for the CLI
      systemd.packages = [ pkgs.twingate ];

      systemd.services.twingate.preStart = ''
        mkdir -p '/etc/twingate'
        cp -r -n ${pkgs.twingate}/etc/twingate/. /etc/twingate/
      '';

      systemd.services.twingate.wantedBy = [ "multi-user.target" ];
    })
  ]);
}
