{
  config,
  pkgs,
  lib,
  ...
}:

with lib;
let
  cfg = config.soxincfg.settings.fonts;
in
{
  # TODO: find a nice way of selecting a default font.
  options = {
    soxincfg.settings.fonts = {
      enable = mkEnableOption "Enable default settings for fonts.";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    { }

    { fonts.fontconfig.enable = true; }
  ]);
}
