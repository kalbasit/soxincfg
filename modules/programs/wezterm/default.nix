{
  mode,
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkIf
    mkMerge
    optionalAttrs
    singleton
    ;

  inherit (pkgs) substituteAll wezterm;

  cfg = config.soxincfg.programs.wezterm;
in
{
  options = {
    soxincfg.programs.wezterm = {
      enable = mkEnableOption "WezTerm terminal emulator";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (optionalAttrs (mode == "home-manager") {
      home.packages = singleton pkgs.wezterm;

      xdg.configFile."wezterm/wezterm.lua".source = substituteAll {
        src = ./wezterm.lua;
        terminfo_dirs = "${wezterm.terminfo}/share/terminfo";
      };
    })
  ]);
}
