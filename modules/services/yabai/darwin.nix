{ config, lib, pkgs, ... }:

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
        "active_window_border_color" = "0xff775759";
        "active_window_opacity" = "1.0";
        "auto_balance" = "off";
        "bottom_padding" = "12";
        "focus_follows_mouse" = "off";
        "insert_feedback_color" = "0xffd75f5f";
        "layout" = "bsp";
        "left_padding" = "12";
        "mouse_action1" = "move";
        "mouse_action2" = "resize";
        "mouse_drop_action" = "swap";
        "mouse_follows_focus" = "off";
        "mouse_modifier" = "fn";
        "normal_window_border_color" = "0xff555555";
        "normal_window_opacity" = "0.90";
        "right_padding" = "12";
        "split_ratio" = "0.50";
        "split_type" = "auto";
        "top_padding" = "15";
        "window_animation_duration" = "0.0";
        "window_animation_frame_rate" = "120";
        "window_border" = "off";
        "window_border_blur" = "off";
        "window_border_hidpi" = "on";
        "window_border_radius" = "12";
        "window_border_width" = "4";
        "window_gap" = "06";
        "window_opacity" = "off";
        "window_opacity_duration" = "0.0";
        "window_origin_display" = "default";
        "window_placement" = "second_child";
        "window_shadow" = "on";
        "window_topmost" = "off";
        "window_zoom_persist" = "on";
      };
    };
  };
}
