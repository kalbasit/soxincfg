{ config, lib, pkgs, ... }:

let
  inherit (lib)
    mkIf
    ;

  cfg = config.soxincfg.services.sketchybar;
in
{
  config = mkIf cfg.enable {
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
  };
}
