{
  mode,
  config,
  pkgs,
  lib,
  ...
}:

with lib;
let
  cfg = config.soxincfg.settings.fonts;
  packages = with pkgs; [
    material-design-icons
    font-awesome

    nerd-fonts._0xproto
    nerd-fonts.symbols-only
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

    (optionalAttrs (mode == "home-manager") { fonts.fontconfig.enable = true; })
  ]);
}
