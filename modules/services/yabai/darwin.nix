{ config, lib, pkgs, ... }:

let
  inherit (lib)
    mkIf
    ;

  cfg = config.soxincfg.services.yabai;
in
{
  config = mkIf cfg.enable {
    launchd.user.agents.yabai.serviceConfig = {
      StandardOutPath = "/var/tmp/yabai.stdout.log";
      StandardErrorPath = "/var/tmp/yabai.stderr.log";
    };

    launchd.daemons.yabai-sa.serviceConfig = {
      StandardOutPath = "/var/tmp/yabai-sa.stdout.log";
      StandardErrorPath = "/var/tmp/yabai-sa.stderr.log";
    };

    services.yabai = {
      enable = true;
      enableScriptingAddition = true;
      config = {
        "active_window_border_color" = "0xffe1e3e4";
        "active_window_opacity" = "1.0";
        "auto_balance" = "off";
        "bottom_padding" = "4";
        "external_bar" = "all:35:0";
        "focus_follows_mouse" = "off";
        "insert_feedback_color" = "0xff9dd274";
        "layout" = "bsp";
        "left_padding" = "4";
        "mouse_action1" = "move";
        "mouse_action2" = "resize";
        "mouse_drop_action" = "swap";
        "mouse_follows_focus" = "off";
        "mouse_modifier" = "fn";
        "normal_window_border_color" = "0xff494d64";
        "normal_window_opacity" = "0.0";
        "right_padding" = "4";
        "split_ratio" = "0.50";
        "top_padding" = "10";
        "window_animation_duration" = "0.1";
        "window_border" = "on";
        "window_border_blur" = "off";
        "window_border_hidpi" = "off";
        "window_border_radius" = "11";
        "window_border_width" = "2";
        "window_gap" = "6";
        "window_opacity" = "off";
        "window_opacity_duration" = "0.0";
        "window_placement" = "second_child";
        "window_shadow" = "float";
        "window_topmost" = "off";
        "window_zoom_persist" = "off";
      };

      extraConfig = ''
        # Unload the macOS WindowManager process
        # launchctl unload -F /System/Library/LaunchAgents/com.apple.WindowManager.plist > /dev/null 2>&1 &

        # yabai -m signal --add event=dock_did_restart action="sudo yabai --load-sa"
        yabai -m signal --add event=window_focused action="sketchybar --trigger window_focus"
        # yabai -m signal --add event=display_added action="sleep 2 && $HOME/.config/yabai/create_spaces.sh"
        # yabai -m signal --add event=display_removed action="sleep 1 && $HOME/.config/yabai/create_spaces.sh"
        yabai -m signal --add event=window_created action="sketchybar --trigger windows_on_spaces"
        yabai -m signal --add event=window_destroyed action="sketchybar --trigger windows_on_spaces"

        # Exclude problematic apps from being managed:
        yabai -m rule --add app="^(LuLu|Calculator|Software Update|Dictionary|VLC|System Preferences|System Settings|zoom.us|Photo Booth|Archive Utility|Python|LibreOffice|App Store|Steam|Alfred|Activity Monitor|DOSBox)$" manage=off
        yabai -m rule --add label="Finder" app="^Finder$" title="(Co(py|nnect)|Move|Info|Pref)" manage=off
        yabai -m rule --add label="Safari" app="^Safari$" title="^(General|(Tab|Password|Website|Extension)s|AutoFill|Se(arch|curity)|Privacy|Advance)$" manage=off
        yabai -m rule --add label="About This Mac" app="System Information" title="About This Mac" manage=off
        yabai -m rule --add label="Select file to save to" app="^Inkscape$" title="Select file to save to" manage=off
      '';
    };
  };
}
