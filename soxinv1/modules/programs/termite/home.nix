{
  config,
  pkgs,
  lib,
  soxinLib,
  ...
}:

with lib;
let
  cfg = config.soxin.programs.termite;
in
{
  options = {
    soxin.programs.termite = soxinLib.mkSoxinModule {
      inherit config;
      name = "termite";
      includeTheme = true;
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      programs.termite = mkMerge [
        { inherit (cfg) enable; }
        cfg.theme.extraConfig
      ];
    }
  ]);
}
