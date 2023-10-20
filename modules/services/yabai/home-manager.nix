{ config, lib, ... }:

let
  inherit (lib)
    mkIf
    ;

  cfg = config.soxincfg.services.yabai;
in
{
  config = mkIf cfg.enable {
    xdg.configFile."yabai/yabairc" = {
      executable = true;

      # TODO: When Nix interacts with launchctl, it gets killed due to
      # segmentation fault. Fix this!
      #
      # onChange = ''
      #   if ! type yabai &>/dev/null; then
      #     yabai() {
      #       if test -x /opt/homebrew/bin/yabai; then
      #         PATH="$PATH:/bin:/usr/bin:/opt/homebrew/bin" yabai "$@"
      #       elif test -x /usr/local/bin/yabai; then
      #         PATH="$PATH:/bin:/usr/bin:/usr/local/bin" yabai "$@"
      #       else
      #         _iError "yabai: No such file or directory" >&2
      #         return 1
      #       fi
      #     }
      #   fi
      #
      #   if ! test -f ${config.home.homeDirectory}/Library/LaunchAgents/com.koekeishiya.yabai.plist; then
      #     _iNote "Installing and starting the yabai service"
      #     yabai --install-service
      #     yabai --start-service
      #   else
      #     _iNote "Restarting the yabai service"
      #     yabai --stop-service &>/dev/null || true
      #     yabai --start-service
      #   fi
      # '';

      text = ''
        yabai -m config active_window_border_color 0xffe1e3e4
        yabai -m config active_window_opacity 1.0
        yabai -m config auto_balance off
        yabai -m config bottom_padding 4
        yabai -m config external_bar all:35:0
        yabai -m config focus_follows_mouse off
        yabai -m config insert_feedback_color 0xff9dd274
        yabai -m config layout bsp
        yabai -m config left_padding 4
        yabai -m config mouse_action1 move
        yabai -m config mouse_action2 resize
        yabai -m config mouse_drop_action swap
        yabai -m config mouse_follows_focus off
        yabai -m config mouse_modifier fn
        yabai -m config normal_window_border_color 0xff494d64
        yabai -m config normal_window_opacity 0.0
        yabai -m config right_padding 4
        yabai -m config split_ratio 0.50
        yabai -m config top_padding 10
        yabai -m config window_animation_duration 0.1
        yabai -m config window_border on
        yabai -m config window_border_blur off
        yabai -m config window_border_hidpi off
        yabai -m config window_border_radius 11
        yabai -m config window_border_width 2
        yabai -m config window_gap 6
        yabai -m config window_opacity off
        yabai -m config window_opacity_duration 0.0
        yabai -m config window_placement second_child
        yabai -m config window_shadow float
        yabai -m config window_topmost off
        yabai -m config window_zoom_persist off

        # Unload the macOS WindowManager process
        # launchctl unload -F /System/Library/LaunchAgents/com.apple.WindowManager.plist > /dev/null 2>&1 &

        yabai -m signal --add event=dock_did_restart action="sudo yabai --load-sa"
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

        # https://github.com/koekeishiya/yabai/issues/1622#issuecomment-1493105964
        yabai -m rule --add app="^Arc$" subrole='AXSystemDialog' manage=off mouse_follows_focus=off
        yabai -m rule --add app='^Arc$' title='^Space.*$' manage=off
      '';
    };
  };
}
