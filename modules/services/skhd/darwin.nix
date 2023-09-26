{ config, lib, ... }:

let
  inherit (lib)
    mkIf
    ;

  cfg = config.soxincfg.services.skhd;
in
{
  config = mkIf cfg.enable {
    homebrew = {
      brews = [ "koekeishiya/formulae/skhd" ];
      taps = [ "koekeishiya/formulae" ];
    };
  };
}
