{
  config,
  hostType,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.soxincfg.programs.t3code;
in
{
  config = lib.mkIf cfg.enable {
    systemd.user.services.t3code = {
      serviceConfig = {
        ExecStart = "${pkgs.t3code}/bin/t3code serve --host 0.0.0.0 --no-browser ~/code --mode web";
        Type = "simple";
        Restart = "on-failure";
      };
      unitConfig.WantedBy = [ "default.target" ];
    };
  };
}
