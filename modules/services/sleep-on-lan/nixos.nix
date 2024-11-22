{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkIf;

  cfg = config.soxincfg.services.sleep-on-lan;
  sopsFile = ./secrets.sops.yaml;
in
{
  config = mkIf cfg.enable {
    sops.secrets.etc_sol_json = {
      inherit sopsFile;
      path = "/etc/sol.json";
    };

    systemd.services.sleep-on-lan = {
      description = "Sleep-On-LAN daemon";
      serviceConfig = {
        User = "root";
        ExecStart = "${pkgs.sleep-on-lan}/bin/sleep-on-lan";
        Restart = "always";
      };
      restartTriggers = [ "/etc/sol.json" ];
      wantedBy = [ "multi-user.target" ];
    };

    networking.firewall = {
      allowedTCPPorts = [ 8009 ];
      allowedUDPPorts = [ 9 ];
    };
  };
}
