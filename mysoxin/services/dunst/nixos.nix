{
  config,
  pkgs,
  lib,
  ...
}:

with lib;
let
  cfg = config.soxin.services.dunst;
in
{
  options = {
    soxin.services.dunst = {
      enable = mkEnableOption "dunst, the notification daemon";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    ({ })
  ]);
}
