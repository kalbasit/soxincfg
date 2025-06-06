{
  mode,
  config,
  pkgs,
  lib,
  ...
}:

with lib;
let
  cfg = config.soxin.services.dunst;
in
{
  options = {
    soxin.services.dunst = {
      enable = mkEnableOption "dunst, the notification daemon";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (optionalAttrs (mode == "home-manager") {
      services.dunst = {
        enable = true;
        settings = {
          global = {
            # Allow a small subset of html markup:
            #   <b>bold</b>
            #   <i>italic</i>
            #   <s>strikethrough</s>
            #   <u>underline</u>
            #
            # For a complete reference see
            # <http://developer.gnome.org/pango/stable/PangoMarkupFormat.html>.
            # If markup is not allowed, those tags will be stripped out of the
            # message.
            allow_markup = true;
            plain_text = false;

            # The format of the message.  Possible variables are:
            #   %a  appname
            #   %s  summary
            #   %b  body
            #   %i  iconname (including its path)
            #   %I  iconname (without its path)
            #   %p  progress value if set ([  0%] to [100%]) or nothing
            # Markup is allowed
            format = "<b>%s</b>\\n%b";

            # Sort messages by urgency.
            sort = true;

            # Show how many messages are currently hidden (because of geometry).
            indicate_hidden = true;

            # Alignment of message text.
            # Possible values are "left", "center" and "right".
            alignment = "center";

            # The frequency with wich text that is longer than the notification
            # window allows bounces back and forth.
            # This option conflicts with "word_wrap".
            # Set to 0 to disable.
            bounce_freq = 0;

            # Show age of message if message is older than show_age_threshold
            # seconds.
            # Set to -1 to disable.
            show_age_threshold = 60;

            # Split notifications into multiple lines if they don't fit into
            # geometry.
            word_wrap = true;

            # Ignore newlines '\n' in notifications.
            ignore_newline = false;

            # Hide duplicate's count and stack them
            stack_duplicates = true;
            hide_duplicates_count = true;

            # The geometry of the window:
            #   [{width}]x{height}[+/-{x}+/-{y}]
            # The geometry of the message window.
            # The height is measured in number of notifications everything else
            # in pixels.  If the width is omitted but the height is given
            # ("-geometry x2"), the message window expands over the whole screen
            # (dmenu-like).  If width is 0, the window expands to the longest
            # message displayed.  A positive x is measured from the left, a
            # negative from the right side of the screen.  Y is measured from
            # the top and down respectevly.
            # The width can be negative.  In this case the actual width is the
            # screen width minus the width defined in within the geometry option.
            #geometry = "250x50-40+40"
            geometry = mkDefault "300x50-15+49";

            # Shrink window if it's smaller than the width.  Will be ignored if
            # width is 0.
            shrink = false;

            # The transparency of the window.  Range: [0; 100].
            # This option will only work if a compositing windowmanager is
            # present (e.g. xcompmgr, compiz, etc.).
            transparency = 5;

            # Don't remove messages, if the user is idle (no mouse or keyboard input)
            # for longer than idle_threshold seconds.
            # Set to 0 to disable.
            idle_threshold = 0;

            # Which monitor should the notifications be displayed on.
            monitor = 0;

            # Display notification on focused monitor.  Possible modes are:
            #   mouse: follow mouse pointer
            #   keyboard: follow window with keyboard focus
            #   none: don't follow anything
            #
            # "keyboard" needs a windowmanager that exports the
            # _NET_ACTIVE_WINDOW property.
            # This should be the case for almost all modern windowmanagers.
            #
            # If this option is set to mouse or keyboard, the monitor option
            # will be ignored.
            follow = "none";

            # Should a notification popped up from history be sticky or timeout
            # as if it would normally do.
            sticky_history = true;

            # Maximum amount of notifications kept in history
            history_length = 15;

            # Display indicators for URLs (U) and actions (A).
            show_indicators = true;

            # The height of a single line.  If the height is smaller than the
            # font height, it will get raised to the font height.
            # This adds empty space above and under the text.
            line_height = 3;

            # Draw a line of "separatpr_height" pixel height between two
            # notifications.
            # Set to 0 to disable.
            separator_height = 2;

            # Padding between text and separator.
            padding = 6;

            # Horizontal padding.
            horizontal_padding = 6;

            # Define a color for the separator.
            # possible values are:
            #  * auto: dunst tries to find a color fitting to the background;
            #  * foreground: use the same color as the foreground;
            #  * frame: use the same color as the frame;
            #  * anything else will be interpreted as a X color.
            separator_color = "frame";

            # Print a notification on startup.
            # This is mainly for error detection, since dbus (re-)starts dunst
            # automatically after a crash.
            startup_notification = false;

            # dmenu path.
            dmenu = "${pkgs.rofi}/bin/rofi -dmenu -p dunst:";

            # Browser for opening urls in context menu.
            browser = "rbrowser";

            ### mouse

            # Defines list of actions for each mouse event
            # Possible values are:
            # * none: Don't do anything.
            # * do_action: If the notification has exactly one action, or one is marked as default,
            #              invoke it. If there are multiple and no default, open the context menu.
            # * close_current: Close current notification.
            # * close_all: Close all notifications.
            # These values can be strung together for each mouse event, and
            # will be executed in sequence.
            mouse_middle_click = "close_all";
            mouse_left_click = "do_action, close_current";
            mouse_right_click = "close_current";
          };

          frame = {
            width = 3;
            color = "#8EC07C";
          };

          shortcuts = {
            # Shortcuts are specified as [modifier+][modifier+]...key
            # Available modifiers are "ctrl", "mod1" (the alt-key), "mod2",
            # "mod3" and "mod4" (windows-key).
            # Xev might be helpful to find names for keys.

            # Close notification.
            close = "ctrl+space";

            # Close all notifications.
            close_all = "ctrl+shift+space";

            # Redisplay last message(s).
            # On the US keyboard layout "grave" is normally above TAB and left
            # of "1".
            history = "ctrl+grave";

            # Context menu.
            context = "ctrl+shift+period";
          };

          urgency_low = {
            # IMPORTANT: colors have to be defined in quotation marks.
            # Otherwise the "#" and following would be interpreted as a comment.
            frame_color = "#3B7C87";
            foreground = "#3B7C87";
            background = "#191311";
            #background = "#2B313C";
            timeout = 4;
          };

          urgency_normal = {
            frame_color = "#5B8234";
            foreground = "#5B8234";
            background = "#191311";
            #background = "#2B313C";
            timeout = 6;
          };

          urgency_critical = {
            frame_color = "#B7472A";
            foreground = "#B7472A";
            background = "#191311";
            #background = "#2B313C";
            timeout = 8;
          };
        };
      };
    })
  ]);
}
