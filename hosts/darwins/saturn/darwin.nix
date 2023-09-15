{ config, lib, pkgs, inputs, soxincfg, ... }:

let
  inherit (lib)
    singleton
    ;
in
{
  imports = [
    soxincfg.nixosModules.profiles.myself
    soxincfg.nixosModules.profiles.workstation.darwin.local
  ]
  ++ (soxincfg.nixosModules.profiles.work.imports { hostName = "saturn"; });

  # load YL's home-manager configuration
  home-manager.users.yl = import ./home.nix { inherit soxincfg; };

  # TODO: Make gpg work, and re-enable this.
  soxincfg.programs.git.enableGpgSigningKey = false;

  nix = {
    useDaemon = true;
  };

  services.sketchybar = {
    enable = true;
    config = ''
      # This is a demo config to show some of the most important commands more easily.
      # This is meant to be changed and configured, as it is intentionally kept sparse.
      # For a more advanced configuration example see my dotfiles:
      # https://github.com/FelixKratz/dotfiles

      PLUGIN_DIR="${pkgs.sketchybar.src}/plugins"

      ##### Bar Appearance #####
      # Configuring the general appearance of the bar, these are only some of the
      # options available. For all options see:
      # https://felixkratz.github.io/SketchyBar/config/bar
      # If you are looking for other colors, see the color picker:
      # https://felixkratz.github.io/SketchyBar/config/tricks#color-picker

      sketchybar --bar height=32        \
                       blur_radius=30   \
                       position=top     \
                       sticky=off       \
                       padding_left=10  \
                       padding_right=10 \
                       color=0x15ffffff

      ##### Changing Defaults #####
      # We now change some default values that are applied to all further items
      # For a full list of all available item properties see:
      # https://felixkratz.github.io/SketchyBar/config/items

      sketchybar --default icon.font="Hack Nerd Font:Bold:17.0"  \
                           icon.color=0xffffffff                 \
                           label.font="Hack Nerd Font:Bold:14.0" \
                           label.color=0xffffffff                \
                           padding_left=5                        \
                           padding_right=5                       \
                           label.padding_left=4                  \
                           label.padding_right=4                 \
                           icon.padding_left=4                   \
                           icon.padding_right=4

      ##### Adding Mission Control Space Indicators #####
      # Now we add some mission control spaces:
      # https://felixkratz.github.io/SketchyBar/config/components#space----associate-mission-control-spaces-with-an-item
      # to indicate active and available mission control spaces

      SPACE_ICONS=("1" "2" "3" "4" "5" "6" "7" "8" "9" "10")

      for i in "''${!SPACE_ICONS[@]}"
      do
        sid=$(($i+1))
        sketchybar --add space space.$sid left                                 \
                   --set space.$sid associated_space=$sid                      \
                                    icon=''${SPACE_ICONS[i]}                   \
                                    background.color=0x44ffffff                \
                                    background.corner_radius=5                 \
                                    background.height=20                       \
                                    background.drawing=off                     \
                                    label.drawing=off                          \
                                    script="$PLUGIN_DIR/space.sh"              \
                                    click_script="yabai -m space --focus $sid"
      done

      ##### Adding Left Items #####
      # We add some regular items to the left side of the bar
      # only the properties deviating from the current defaults need to be set

      sketchybar --add item space_separator left                         \
                 --set space_separator icon=                            \
                                       padding_left=10                   \
                                       padding_right=10                  \
                                       label.drawing=off                 \
                                                                         \
                 --add item front_app left                               \
                 --set front_app       script="$PLUGIN_DIR/front_app.sh" \
                                       icon.drawing=off                  \
                 --subscribe front_app front_app_switched

      ##### Adding Right Items #####
      # In the same way as the left items we can add items to the right side.
      # Additional position (e.g. center) are available, see:
      # https://felixkratz.github.io/SketchyBar/config/items#adding-items-to-sketchybar

      # Some items refresh on a fixed cycle, e.g. the clock runs its script once
      # every 10s. Other items respond to events they subscribe to, e.g. the
      # volume.sh script is only executed once an actual change in system audio
      # volume is registered. More info about the event system can be found here:
      # https://felixkratz.github.io/SketchyBar/config/events

      sketchybar --add item clock right                              \
                 --set clock   update_freq=10                        \
                               icon=                                \
                               script="$PLUGIN_DIR/clock.sh"         \
                                                                     \
                 --add item wifi right                               \
                 --set wifi    script="$PLUGIN_DIR/wifi.sh"          \
                               icon=                                \
                 --subscribe wifi wifi_change                        \
                                                                     \
                 --add item volume right                             \
                 --set volume  script="$PLUGIN_DIR/volume.sh"        \
                 --subscribe volume volume_change                    \
                                                                     \
                 --add item battery right                            \
                 --set battery script="$PLUGIN_DIR/battery.sh"       \
                               update_freq=120                       \
                 --subscribe battery system_woke power_source_change

      ##### Finalizing Setup #####
      # The below command is only needed at the end of the initial configuration to
      # force all scripts to run the first time, it should never be run in an item script.

      sketchybar --update
    '';
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
      "top_padding" = "12";
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
}
