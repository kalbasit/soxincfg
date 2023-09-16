{ config, lib, pkgs, ... }:

let
  inherit (lib)
    mkIf
    ;

  cfg = config.soxincfg.services.skhd;
in
{
  config = mkIf cfg.enable {
    launchd.user.agents.skhd.serviceConfig = {
      StandardOutPath = "/var/tmp/skhd.stdout.log";
      StandardErrorPath = "/var/tmp/skhd.stderr.log";
    };

    services.skhd = {
      enable = true;
      skhdConfig = ''
        # focus window
        alt - n : yabai -m window --focus west
        alt - e : yabai -m window --focus south
        alt - i : yabai -m window --focus north
        alt - o : yabai -m window --focus east

        # swap window
        shift + alt - n : yabai -m window --swap west
        shift + alt - e : yabai -m window --swap south
        shift + alt - i : yabai -m window --swap north
        shift + alt - o : yabai -m window --swap east

        # toggle window zoom
        alt - f : yabai -m window --toggle zoom-fullscreen
      '';
    };
  };
}
