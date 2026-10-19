{
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
    { }
  ]);
}
