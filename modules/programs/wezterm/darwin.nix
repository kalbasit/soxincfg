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
    { }
  ]);
}
