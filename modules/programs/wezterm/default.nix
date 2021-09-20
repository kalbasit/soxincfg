{ mode, config, pkgs, lib, ... }:

let
  inherit(lib)
    mkEnableOption
    mkIf
    mkMerge
    optionalAttrs
    singleton
  ;

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
      xdg.configFile."wezterm/wezterm.lua".source = ./wezterm.lua;
    })
  ]);
}
