{
  config,
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
      Unit = {
        Description = "t3code web server";
      };

      Service = {
        ExecStart = "${pkgs.t3code}/bin/t3code serve --host 0.0.0.0 --no-browser ~/code --mode web";
        Type = "simple";
        Restart = "on-failure";
      };

      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };
}
