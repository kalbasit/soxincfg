{
  mode,
  config,
  pkgs,
  lib,
  ...
}:

with lib;
let
  cfg = config.soxin.services.caffeine;
in
{
  options = {
    soxin.services.caffeine = {
      enable = mkEnableOption "Whether to enable caffeine-ng.";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (optionalAttrs (mode == "home-manager") {
      systemd.user.services.caffeine-ng = {
        Unit = {
          Description = "Caffeine-ng, a locker inhibitor";
          After = [ "graphical-session-pre.target" ];
          PartOf = [ "graphical-session.target" ];
        };

        Install = {
          WantedBy = [ "graphical-session.target" ];
        };

        Service = {
          ExecStart = "${pkgs.caffeine-ng}/bin/caffeine";
        };
      };
    })
  ]);
}
