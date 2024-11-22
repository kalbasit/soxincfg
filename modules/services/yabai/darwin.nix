{ config, lib, ... }:

let
  inherit (lib) mkIf;

  cfg = config.soxincfg.services.yabai;
in
{
  config = mkIf cfg.enable {
    homebrew = {
      brews = [ "koekeishiya/formulae/yabai" ];
      taps = [ "koekeishiya/formulae" ];
    };
  };
}
