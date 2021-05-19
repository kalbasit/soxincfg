{ mode, config, pkgs, lib, ... }:

with lib;
let
  cfg = config.soxin.settings.fonts;
in
{
  # TODO: find a nice way of selecting a default font.
  options = {
    soxin.settings.fonts = {
      enable = mkEnableOption "Enable default settings for fonts.";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (optionalAttrs (mode == "NixOS") {
      fonts = {
        enableDefaultFonts = true;
        fontDir.enable = true;
        enableGhostscriptFonts = true;

        fonts = with pkgs; [
          powerline-fonts
          twemoji-color-font

          noto-fonts
          noto-fonts-extra
          noto-fonts-emoji
          noto-fonts-cjk

          symbola
          vegur
          b612
        ];
      };
    })

    {
      fonts.fontconfig.enable = true;
    }
  ]);
}
