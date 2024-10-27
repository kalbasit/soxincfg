{ config, pkgs, lib, master }:

with lib;
let
  # basic key combinations.
  alt = "Mod1";
  ctrl = "Control";
  meta = "Mod4";
  shift = "Shift";

  # complex key combinations.
  hyper = "${alt}+${shift}+${ctrl}+${meta}";
  meh = "${alt}+${shift}+${ctrl}";

  nosid = "--no-startup-id";
  locker = "xset s activate";

  jrnlEntry = pkgs.writeScript "jrnl-entry.sh" ''
    #!/usr/bin/env bash

    set -euo pipefail

    readonly current_workspace="$( ${getBin pkgs.i3}/bin/i3-msg -t get_workspaces | ${getBin pkgs.jq}/bin/jq -r '.[] | if .focused == true then .name else empty end'  )"
    readonly current_profile="$( echo "$current_workspace" | cut -d\@ -f1  )"
    readonly current_story="$( echo "$current_workspace" | cut -d\@ -f2  )"

    # create a temporary file for the jrnl entry
    jrnl_entry="$(mktemp)"
    trap "rm $jrnl_entry" EXIT

    cat <<EOF > "$jrnl_entry"
    # All lines starting with a hash sign are treated as comments and not added to the journal entry.
    # You are adding a journal entry for profile=$current_profile and story=$current_story
    # computed from the workspace $current_workspace

    @$current_story

    EOF

    # open a new terminal window with vim session inside of it to edit the jrnl entry
    readonly line_count="$(wc -l "$jrnl_entry" | awk '{print $1}')"
    ${getBin pkgs.termite}/bin/termite --title jrnl_entry --exec="nvim +$line_count +star -c 'set wrap' -c 'set textwidth=80' -c 'set fo+=t' $jrnl_entry"
    readonly content="$( grep -v '^#' "$jrnl_entry" )"

    ${getBin pkgs.jrnl}/bin/jrnl "$current_profile" "$content"
  '';
in
{
  enable = true;

  config =
    {
      bars = [ ];

      fonts = { names = [ "pango:Source Code Pro for Powerline" ]; size = 12.0; };

      window = {
        commands = [
          {
            command = "floating enable";
            criteria = { workspace = "^studio$"; };
          }

          { command = "floating enable"; criteria = { class = "^Arandr"; }; }
          { command = "floating enable"; criteria = { class = "^Pavucontrol"; }; }
          { command = "floating enable"; criteria = { class = "^ROX-Filer$"; }; }
          { command = "floating enable"; criteria = { class = "^SimpleScreenRecorder$"; }; }
          { command = "floating enable"; criteria = { class = "^Tor Browser"; }; }
          { command = "floating enable"; criteria = { class = "^net-filebot-Main$"; }; }
          { command = "floating enable"; criteria = { title = "^jrnl_entry$"; }; }

          { command = "sticky enable, floating enable, move scratchpad"; criteria = { class = "MellowPlayer"; }; }
        ];
      };

      floating = { modifier = "${meta}"; };

      focus = {
        # focus should not follow the mouse pointer
        followMouse = false;

        # on window activation, just set the urgency hint. The default behavior is to
        # set the urgency hint if the window is not on the active workspace, and to
        # focus the window on an active workspace. It does surprise me sometimes and I
        # would like to keep it simple by having to manually switch to the urgent
        # window.
        newWindow = "urgent";
      };

      assigns = {
        "charles" = [{ class = "^com-xk72-charles-gui-.*$"; }];
        "discord" = [{ class = "^discord$"; }];
        "element" = [{ class = "^Element$"; }];
        "keybase" = [{ class = "^Keybase$"; }];
        "signal" = [{ class = "^Signal$"; }];
        "whatsapp" = [{ class = "^Whatsapp-for-linux$"; }];
        "slack" = [{ class = "^Slack$"; }];
        "studio" = [{ class = "^obs$"; }];
        "tor" = [{ class = "^Tor Browser"; }];
        "virtualbox" = [{ class = "^VirtualBox"; }];
      };

      modifier = "Mod4";

      keybindings = {
        # change focus
        "${meta}+n" = "focus left";
        "${meta}+e" = "focus down";
        "${meta}+i" = "focus up";
        "${meta}+o" = "focus right";

        # move focused window
        "${meta}+${shift}+n" = "move left";
        "${meta}+${shift}+e" = "move down";
        "${meta}+${shift}+i" = "move up";
        "${meta}+${shift}+o" = "move right";

        # split in horizontal orientation
        "${meta}+h" = "split h";

        # split in vertical orientation
        "${meta}+v" = "split v";

        # change focus between output
        "${meh}+n" = "focus output left";
        "${meh}+e" = "focus output down";
        "${meh}+i" = "focus output up";
        "${meh}+o" = "focus output right";

        # move workspaces between monitors
        "${hyper}+n" = "move workspace to output left";
        "${hyper}+e" = "move workspace to output down";
        "${hyper}+i" = "move workspace to output up";
        "${hyper}+o" = "move workspace to output right";

        # toggle sticky
        "${meta}+s" = "sticky toggle";

        # change focus between tiling / floating windows
        "${alt}+f" = "focus mode_toggle";

        # toggle tiling / floating
        "${alt}+${shift}+f" = "floating toggle";

        # jrnl entry
        "${alt}+j" = "exec ${jrnlEntry}";

        # enter fullscreen mode for the focused container
        "${meta}+f" = "fullscreen toggle";

        # kill focused window
        "${meta}+${shift}+q" = "kill";

        # rbrowser
        "${meta}+b" = "exec rbrowser";

        # Emoji
        "${meta}+${alt}+e" = "exec rofi -show emoji";

        # rofi run
        "${meta}+r" = "exec rofi -show run";

        # list open windows to switch to
        "${alt}+Tab" = "exec rofi -show window";

        # switch between the current and the previously focused one
        "${meta}+Tab" = "workspace back_and_forth";
        "${meta}+${shift}+Tab" = "move container to workspace back_and_forth";

        # dynamic workspaces
        "${meta}+space" = "exec rofi -show i3SwapWorkspaces";
        "${alt}+space" = "exec rofi -show i3Workspaces";
        "${meta}+${shift}+space" = "exec rofi -show i3MoveContainer";
        "${meta}+${alt}+space" = "exec rofi -show i3RenameWorkspace";

        # focus the parent container
        "${meta}+a" = "focus parent";

        # focus the child container
        "${meta}+d" = "focus child";

        # start a region screenshot
        "${meta}+${shift}+4" = "exec ${getBin pkgs.flameshot}/bin/flameshot gui --delay 500 --path ${config.home.homeDirectory}/Desktop";

        # start a screen recorder
        "${meta}+${shift}+5" = "exec ${getBin pkgs.simplescreenrecorder}/bin/simplescreenrecorder";

        # focus the urgent window
        "${meta}+x" = "[urgent=latest] focus";

        # mark current window / goto mark
        # https://github.com/tybitsfox/i3msg/blob/master/.i3/config
        "${meta}+m" = "exec i3-input -F 'mark %s' -l 1 -P 'Mark: '";
        "${meta}+apostrophe" = "exec i3-input -F '[con_mark=\"%s\"] focus' -l 1 -P 'Go to: '";

        # volume support
        "XF86AudioRaiseVolume" = "exec ${nosid} ${getBin pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ false, exec ${nosid} ${getBin pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ +5%";
        "XF86AudioLowerVolume" = "exec ${nosid} ${getBin pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ false, exec ${nosid} ${getBin pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ -5%";
        "XF86AudioMute" = "exec ${nosid} ${getBin pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle";
        "XF86AudioMicMute" = "exec ${nosid} ${getBin pkgs.pulseaudio}/bin/pactl set-source-mute @DEFAULT_SOURCE@ toggle";

        # brightness support
        "XF86MonBrightnessUp" = "exec ${nosid} ${getBin pkgs.brightnessctl}/bin/brightnessctl s +5%";
        "XF86MonBrightnessDown" = "exec ${nosid} ${getBin pkgs.brightnessctl}/bin/brightnessctl s 5%-";
        "${shift}+XF86MonBrightnessUp" = "exec ${nosid} ${getBin pkgs.brightnessctl}/bin/brightnessctl s +1%";
        "${shift}+XF86MonBrightnessDown" = "exec ${nosid} ${getBin pkgs.brightnessctl}/bin/brightnessctl s 1%-";

        # sleep support
        "XF86PowerOff" = "exec ${nosid} systemctl suspend";

        # lock support
        "${meta}+l" = "exec ${nosid} ${locker}";

        # clipboard history
        "${meta}+${alt}+c" = "exec CM_LAUNCHER=rofi ${getBin pkgs.clipmenu}/bin/clipmenu";

        # Terminals
        "${meta}+Return" = "exec ${nosid} ${getBin pkgs.wezterm}/bin/wezterm";
        "${meta}+${shift}+Return" = "exec ${getBin pkgs.termite}/bin/termite";

        # Modes
        "${meta}+${alt}+r" = "mode resize";
        "${meta}+${alt}+m" = "mode move";

        # Make the currently focused window a scratchpad
        "${meta}+${shift}+minus" = "move scratchpad";

        # Show the next scratchpad windows
        "${alt}+minus" = "scratchpad show";

        # Short-cuts for windows hidden in the scratchpad.
        "${alt}+m" = "[class=\"MellowPlayer\"] scratchpad show";
      };

      modes = {
        resize = {
          # Micro resizement
          "${ctrl}+n" = "resize shrink width 10 px or 1 ppt";
          "${ctrl}+e" = "resize grow height 10 px or 1 ppt";
          "${ctrl}+i" = "resize shrink height 10 px or 1 ppt";
          "${ctrl}+o" = "resize grow width 10 px or 1 ppt";

          # Normal resizing
          "n" = "resize shrink width 50 px or 5 ppt";
          "e" = "resize grow height 50 px or 5 ppt";
          "i" = "resize shrink height 50 px or 5 ppt";
          "o" = "resize grow width 50 px or 5 ppt";

          # Macro resizing
          "${shift}+n" = "resize shrink width 100 px or 10 ppt";
          "${shift}+e" = "resize grow height 100 px or 10 ppt";
          "${shift}+i" = "resize shrink height 100 px or 10 ppt";
          "${shift}+o" = "resize grow width 100 px or 10 ppt";

          # back to normal: Enter or Escape
          "Return" = "mode default";
          "Escape" = "mode default";
        };

        move = {
          # Micro movement
          "${ctrl}+n" = "move left 10 px";
          "${ctrl}+e" = "move down 10 px";
          "${ctrl}+i" = "move up 10 px";
          "${ctrl}+o" = "move right 10 px";

          # Normal resizing
          "n" = "move left 50 px";
          "e" = "move down 50 px";
          "i" = "move up 50 px";
          "o" = "move right 50 px";

          # Macro resizing
          "${shift}+n" = "move left 100 px";
          "${shift}+e" = "move down 100 px";
          "${shift}+i" = "move up 100 px";
          "${shift}+o" = "move right 100 px";

          # back to normal: Enter or Escape
          "Return" = "mode default";
          "Escape" = "mode default";
        };
      };

      startup = [
        { command = "${getBin pkgs.xorg.xset}/bin/xset r rate 300 30"; always = false; notification = false; }
        { command = "i3-msg \"workspace personal; exec ${nosid} ${getBin pkgs.wezterm}/bin/wezterm\""; always = false; notification = true; }
        { command = "${getBin pkgs.synology-drive-client}/bin/synology-drive"; always = false; notification = true; }
      ];
    };

  extraConfig = ''
    # keep the urgency border of a window for 500ms
    # TODO: move this to the i3 module via PR
    force_display_urgency_hint 500 ms

    # This option determines in which mode new containers on workspace level will
    # start.
    # TODO: move this to the i3 module via PR
    workspace_layout tabbed

    #########
    # Modes #
    #########

    set $launcher Launch: (a)pps, (d)aemons, (l)ayout, (p)ower, (s)ettings, (w)indow manager
    mode "$launcher" {
      bindsym a mode "$app_mode"
      bindsym d mode "$daemon_mode"
      bindsym l mode "$layout_mode"
      bindsym p mode "$power_mode"
      bindsym s mode "$settings_mode"
      bindsym w mode "$wm_mode"

      # back to normal: Enter or Escape
      bindsym Return mode default
      bindsym Escape mode default
    }
    bindsym ${meta}+${alt}+l mode "$launcher"

      set $app_mode Applications: (a)stroid, (b)itwarden (o)bs, (m)elloPlayer, (s)ocial
      mode "$app_mode" {
        bindsym a exec astroid, mode default
        bindsym b exec ${getBin pkgs.bitwarden}/bin/bitwarden, mode default
        bindsym o exec ${getBin pkgs.obs-studio}/bin/obs, mode default
        bindsym m exec ${getBin pkgs.mellowplayer}/bin/MellowPlayer, mode default
        bindsym s mode "$social_mode"

        bindsym Escape mode "$launcher"
      }

        set $social_mode Social: (d)iscord, (e)lement${optionalString config.soxin.programs.keybase.enable ", (k)eybase"}, S(l)ack, (s)ignal, (w)hats app
        mode "$social_mode" {
          bindsym d exec ${getBin pkgs.discord}/bin/Discord, mode default
          bindsym e exec ${getBin pkgs.element-desktop}/bin/element-desktop, mode default
          ${optionalString config.soxin.programs.keybase.enable "bindsym k exec ${getBin pkgs.keybase-gui}/bin/keybase-gui, mode default"}
          bindsym l exec ${getBin pkgs.slack}/bin/slack, mode default
          bindsym s exec ${getBin pkgs.signal-desktop}/bin/signal-desktop, mode default
          bindsym w exec ${getBin pkgs.whatsapp-for-linux}/bin/whatsapp-for-linux, mode default

          bindsym Escape mode "$launcher"
        }

      set $daemon_mode Daemons: (x)cape
      mode "$daemon_mode" {
        bindsym Escape mode "$launcher"
      }

      set $layout_mode Layout: (s)tacking, (t)abbed, (x)toggle split
      mode "$layout_mode" {
        bindsym s layout stacking, mode default
        bindsym t layout tabbed, mode default
        bindsym x layout toggle split, mode default

        bindsym Escape mode "$launcher"
      }

      set $power_mode System: (l)ock, L(o)gout, (s)uspend, (h)ibernate, (r)eboot, (${shift}+s)hutdown
      mode "$power_mode" {
        bindsym l exec ${nosid} ${locker}, mode default
        bindsym o exit
        bindsym s exec ${nosid} systemctl suspend, mode default
        bindsym h exec ${nosid} systemctl hibernate, mode default
        bindsym r exec ${nosid} systemctl reboot
        bindsym ${shift}+s exec ${nosid} systemctl poweroff -i

        bindsym Escape mode "$launcher"
      }

      set $settings_mode Settings: (c)pu, (d)isplay
      mode "$settings_mode" {
        bindsym c mode "$cpu_mode"
        bindsym d mode "$display_mode"

        bindsym Escape mode "$launcher"
      }

        # CPU governor selection
        set $cpu_mode CPU Scaling governor: (p)erformance, P(o)wersave
        mode "$cpu_mode" {
          bindsym p exec ${nosid} pkexec -- ${getBin pkgs.linuxPackages.cpupower}/bin/cpupower frequency-set --governor performance, mode default
          bindsym o exec ${nosid} pkexec -- ${getBin pkgs.linuxPackages.cpupower}/bin/cpupower frequency-set --governor powersave, mode default

          bindsym Escape mode "$settings_mode"
        }

        set $display_mode (A)utoRandr --change
        mode "$display_mode" {
          bindsym a exec ${nosid} ${getBin pkgs.autorandr}/bin/autorandr --change, mode default

          bindsym Escape mode "$settings_mode"
        }

      set $wm_mode WM: (r)eload i3, R(e)start i3
      mode "$wm_mode" {
        bindsym r reload; exec ${nosid} ${getBin pkgs.libnotify}/bin/notify-send 'i3 configuration reloaded', mode default
        bindsym e restart; exec ${nosid} ${getBin pkgs.libnotify}/bin/notify-send 'i3 restarted', mode default

        bindsym Escape mode "$launcher"
      }
  '';
}
