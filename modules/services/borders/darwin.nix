{ config, lib, ... }:

let
  inherit (lib)
    mkIf
    ;

  cfg = config.soxincfg.services.sketchybar;
in
{
  config = mkIf cfg.enable {
    homebrew = {
      brews = [ "FelixKratz/Formulae/borders" ];
      taps = [ "FelixKratz/formulae" ];
    };
  };
}
