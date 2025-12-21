{
  config,
  lib,
  ...
}:

let
  inherit (lib)
    mkIf
    ;

  cfg = config.soxincfg.services.yabai;
in
{
  config = mkIf cfg.enable {
    services.yabai = {
      enable = true;
      enableScriptingAddition = true;

      config = {
        # copied from the example configuration
        "active_window_border_color" = "0xffe1e3e4";
        "active_window_opacity" = "1.0";
        "auto_balance" = "off";
        "bottom_padding" = "8";
        "focus_follows_mouse" = "off";
        "insert_feedback_color" = "0xff9dd274";
        "layout" = "bsp";
        "left_padding" = "8";
        "mouse_action1" = "move";
        "mouse_action2" = "resize";
        "mouse_drop_action" = "swap";
        "mouse_follows_focus" = "off";
        "mouse_modifier" = "fn";
        "normal_window_border_color" = "0xff494d64";
        "normal_window_opacity" = "0.0";
        "right_padding" = "8";
        "split_ratio" = "0.50";
        "top_padding" = "8";
        "window_animation_duration" = "010";
        "window_animation_frame_rate" = "120";
        "window_border" = "on";
        "window_border_blur" = "off";
        "window_border_hidpi" = "on";
        "window_border_radius" = "11";
        "window_border_width" = "2";
        "window_gap" = "10";
        "window_opacity" = "off";
        "window_opacity_duration" = "0.0";
        "window_placement" = "second_child";
        "window_shadow" = "float";
        "window_topmost" = "off";
        "window_zoom_persist" = "off";
      };

      extraConfig = lib.mkMerge [
        ''
          yabai -m signal --add event=dock_did_restart action="sudo yabai --load-sa"

          # Exclude problematic apps from being managed:
          yabai -m rule --add app="^(LuLu|Calculator|Software Update|Dictionary|VLC|System Preferences|System Settings|zoom.us|Photo Booth|Archive Utility|Python|LibreOffice|App Store|Steam|Alfred|Activity Monitor|DOSBox|Tor Browser)$" manage=off
          yabai -m rule --add app="^Fusion$" sub-layer=above manage=off
          yabai -m rule --add label="About This Mac" app="System Information" title="About This Mac" manage=off
          yabai -m rule --add label="Finder" app="^Finder$" title="(Co(py|nnect)|Move|Info|Pref)" manage=off
          yabai -m rule --add label="Safari" app="^Safari$" title="^(General|(Tab|Password|Website|Extension)s|AutoFill|Se(arch|curity)|Privacy|Advance)$" manage=off
          yabai -m rule --add label="Select file to save to" app="^Inkscape$" title="Select file to save to" manage=off

          # https://github.com/koekeishiya/yabai/issues/1622#issuecomment-1493105964
          yabai -m rule --add app="^Arc$" subrole='AXSystemDialog' manage=off mouse_follows_focus=off
          yabai -m rule --add app='^Arc$' title='^Space.*$' manage=off
        ''

        (lib.mkIf config.soxincfg.services.sketchybar.enable ''
          yabai -m signal --add event=window_focused action="sketchybar --trigger window_focus"
        '')
      ];
    };
  };
}
