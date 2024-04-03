{ mode, config, pkgs, lib, ... }:

with lib;
let
  cfg = config.soxincfg.settings.fonts;
  packages = with pkgs; [
    corefonts

    powerline-fonts
    twemoji-color-font

    noto-fonts
    noto-fonts-extra
    noto-fonts-emoji
    noto-fonts-cjk

    b612
    symbola
    vegur
  ];
in
{
  # TODO: find a nice way of selecting a default font.
  options = {
    soxincfg.settings.fonts = {
      enable = mkEnableOption "Enable default settings for fonts.";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (optionalAttrs (mode == "NixOS") {
      fonts = {
        inherit packages;

        enableDefaultPackages = true;
        enableGhostscriptFonts = true;
        fontDir.enable = true;
        fontconfig.enable = true;
      };
    })

    (optionalAttrs (mode == "home-manager") {
      fonts.fontconfig.enable = true;
    })
  ]);
}
