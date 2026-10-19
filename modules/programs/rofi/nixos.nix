{
  config,
  lib,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkIf
    optionals
    ;

  cfg = config.soxincfg.programs.rofi;
in
{
  imports = [ ];

  options.soxincfg.programs.rofi = {
    enable = mkEnableOption "programs.rofi";
  };

  config = mkIf cfg.enable {
    soxin.programs.rofi = {
      enable = true;
      i3.enable = true;
    };
  };
}
