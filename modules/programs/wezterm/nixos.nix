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
    optionalAttrs
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
    { }
  ]);
}
