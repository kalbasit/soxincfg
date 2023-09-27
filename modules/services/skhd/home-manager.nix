{ config, lib, ... }:

let
  inherit (lib)
    mkIf
    ;

  cfg = config.soxincfg.services.skhd;
in
{
  config = mkIf cfg.enable {
    xdg.configFile."skhd/skhdrc" = {
      onChange = ''
        if ! test -f ${config.home.homeDirectory}/Library/LaunchAgents/com.koekeishiya.skhd.plist; then
          skhd --install-service
          skhd --start-service
        else
          skhd --stop-service || true
          skhd --start-service
        fi
      '';

      text = ''
        # focus window
        alt - n : yabai -m window --focus west || yabai -m display --focus west
        alt - e : yabai -m window --focus south || yabai -m display --focus south
        alt - i : yabai -m window --focus north || yabai -m display --focus north
        alt - o : yabai -m window --focus east || yabai -m display --focus east

        # Float / Unfloat window: lalt - space
        alt - space : yabai -m window --toggle float; sketchybar --trigger window_focus

        # swap window
        shift + alt - n : yabai -m window --warp west || $(yabai -m window --display west && sketchybar --trigger windows_on_spaces && yabai -m display --focus west && yabai -m window --warp last) || yabai -m window --move rel:-10:0
        shift + alt - e : yabai -m window --warp south || $(yabai -m window --display south && sketchybar --trigger windows_on_spaces && yabai -m display --focus south) || yabai -m window --move rel:0:10
        shift + alt - i : yabai -m window --warp north || $(yabai -m window --display north && sketchybar --trigger windows_on_spaces && yabai -m display --focus north) || yabai -m window --move rel:0:-10
        shift + alt - o : yabai -m window --warp east || $(yabai -m window --display east && sketchybar --trigger windows_on_spaces && yabai -m display --focus east && yabai -m window --warp first) || yabai -m window --move rel:10:0

        # toggle window zoom
        alt - f : yabai -m window --toggle zoom-parent; sketchybar --trigger window_focus
        shift + alt - f : yabai -m window --toggle zoom-fullscreen; sketchybar --trigger window_focus

        # Equalize size of windows: ctrl + alt - e
        ctrl + alt - e : yabai -m space --balance

        # Insertion (shift + ctrl + alt - ...)
        # Set insertion point for focused container: shift + ctrl + alt - {n, e, i, o}
        shift + ctrl + lalt - n : yabai -m window --insert west
        shift + ctrl + lalt - e : yabai -m window --insert south
        shift + ctrl + lalt - i : yabai -m window --insert north
        shift + ctrl + lalt - o : yabai -m window --insert east
      '';
    };
  };
}
