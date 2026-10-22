{
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
    singleton
    ;

  inherit (pkgs) replaceVars wezterm;

  cfg = config.soxincfg.programs.wezterm;
in
{
  options = {
    soxincfg.programs.wezterm = {
      enable = mkEnableOption "WezTerm terminal emulator";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      home.packages = singleton pkgs.wezterm;

      xdg.configFile."wezterm/wezterm.lua".source = replaceVars ./wezterm.lua {
        terminfo_dirs = "${wezterm.terminfo}/share/terminfo";
      };
    }
  ]);
}
