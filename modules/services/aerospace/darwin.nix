{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.soxincfg.services.aerospace;
in
{
  config = lib.mkIf cfg.enable {
    services.aerospace = {
      enable = true;
      package = pkgs.aerospace;
      settings = {
        # Config version for compatibility and deprecations
        # Fallback value (if you omit the key): config-version = 1
        config-version = 2;

        # You can use it to add commands that run after AeroSpace startup.
        # Available commands : https://nikitabobko.github.io/AeroSpace/commands
        after-startup-command = [ ];

        # # Start AeroSpace at login
        #         start-at-login = true;

        # Normalizations. See: https://nikitabobko.github.io/AeroSpace/guide#normalization
        enable-normalization-flatten-containers = true;
        enable-normalization-opposite-orientation-for-nested-containers = true;

        # See: https://nikitabobko.github.io/AeroSpace/guide#layouts
        # The 'accordion-padding' specifies the size of accordion padding
        # You can set 0 to disable the padding feature
        accordion-padding = 30;

        # Possible values: tiles|accordion
        default-root-container-layout = "tiles";

        # Possible values: horizontal|vertical|auto
        # 'auto' means: wide monitor (anything wider than high) gets horizontal orientation,
        #               tall monitor (anything higher than wide) gets vertical orientation
        default-root-container-orientation = "auto";

        # Mouse follows focus when focused monitor changes
        # Drop it from your config, if you don't like this behavior
        # See https://nikitabobko.github.io/AeroSpace/guide#on-focus-changed-callbacks
        # See https://nikitabobko.github.io/AeroSpace/commands#move-mouse
        # Fallback value (if you omit the key): on-focused-monitor-changed = []
        on-focused-monitor-changed = [ "move-mouse monitor-lazy-center" ];

        # You can effectively turn off macOS "Hide application" (cmd-h) feature by toggling this flag
        # Useful if you don't use this macOS feature, but accidentally hit cmd-h or cmd-alt-h key
        # Also see: https://nikitabobko.github.io/AeroSpace/goodies#disable-hide-app
        automatically-unhide-macos-hidden-apps = true;

        # List of workspaces that should stay alive even when they contain no windows,
        # even when they are invisible.
        # This config version is only available since 'config-version = 2'
        # Fallback value (if you omit the key): persistent-workspaces = []
        persistent-workspaces = [
          "1"
          "2"
          "3"
          "4"
          "5"
          "6"
          "7"
          "8"
          "9"
          "10"
        ];

        # A callback that runs every time binding mode changes
        # See: https://nikitabobko.github.io/AeroSpace/guide#binding-modes
        # See: https://nikitabobko.github.io/AeroSpace/commands#mode
        on-mode-changed = [ ];

        # Possible values: (qwerty|dvorak|colemak)
        # See https://nikitabobko.github.io/AeroSpace/guide#key-mapping
        key-mapping.preset = "qwerty";

        # Gaps between windows (inner-*) and between monitor edges (outer-*).
        # Possible values:
        # - Constant:     gaps.outer.top = 8
        # - Per monitor:  gaps.outer.top = [{ monitor.main = 16 }, { monitor."some-pattern" = 32 }, 24]
        #                 In this example, 24 is a default value when there is no match.
        #                 Monitor pattern is the same as for 'workspace-to-monitor-force-assignment'.
        #                 See:
        #                 https://nikitabobko.github.io/AeroSpace/guide#assign-workspaces-to-monitors
        gaps.inner = {
          horizontal = 5;
          vertical = 5;
        };

        mode = {
          # 'main' binding mode declaration
          # See: https://nikitabobko.github.io/AeroSpace/guide#binding-modes
          # 'main' binding mode must be always presented
          # Fallback value (if you omit the key): mode.main.binding = {}
          main.binding = {
            # Disable annoying useless hide application
            cmd-h = [ ];
            cmd-alt-h = [ ];

            # See: https://nikitabobko.github.io/AeroSpace/commands#layout
            alt-t = "layout tiles horizontal vertical";
            alt-a = "layout accordion horizontal vertical";

            # See: https://nikitabobko.github.io/AeroSpace/commands#focus
            alt-n = "focus left";
            alt-e = "focus down";
            alt-i = "focus up";
            alt-o = "focus right";

            # See: https://nikitabobko.github.io/AeroSpace/commands#move
            alt-shift-n = "move left";
            alt-shift-e = "move down";
            alt-shift-i = "move up";
            alt-shift-o = "move right";

            # See: https://nikitabobko.github.io/AeroSpace/commands#fullscreen
            alt-f = "fullscreen";

            # See: https://nikitabobko.github.io/AeroSpace/commands#workspace
            alt-z = "workspace 1";
            alt-x = "workspace 2";
            alt-c = "workspace 3";
            alt-v = "workspace 4";
            alt-b = "workspace 5";
            alt-k = "workspace 6";
            alt-m = "workspace 7";
            alt-comma = "workspace 8";
            alt-period = "workspace 9";
            alt-slash = "workspace 10";

            # See: https://nikitabobko.github.io/AeroSpace/commands#move-node-to-workspace
            alt-shift-z = "move-node-to-workspace 1";
            alt-shift-x = "move-node-to-workspace 2";
            alt-shift-c = "move-node-to-workspace 3";
            alt-shift-v = "move-node-to-workspace 4";
            alt-shift-b = "move-node-to-workspace 5";
            alt-shift-k = "move-node-to-workspace 6";
            alt-shift-m = "move-node-to-workspace 7";
            alt-shift-comma = "move-node-to-workspace 8";
            alt-shift-period = "move-node-to-workspace 9";
            alt-shift-slash = "move-node-to-workspace 10";

            # See: https://nikitabobko.github.io/AeroSpace/commands#workspace-back-and-forth
            alt-tab = "workspace-back-and-forth";

            # See: https://nikitabobko.github.io/AeroSpace/commands#move-workspace-to-monitor
            alt-shift-tab = "move-workspace-to-monitor --wrap-around next";

            # See: https://nikitabobko.github.io/AeroSpace/commands#mode
            alt-r = "mode resize";

            # See: https://nikitabobko.github.io/AeroSpace/commands#mode
            alt-shift-semicolon = "mode service";
          };

          # 'resize' binding mode declaration.
          # See: https://nikitabobko.github.io/AeroSpace/guide#binding-modes
          resize.binding = {
            n = "resize smart -50";
            o = "resize smart +50";

            # See: https://nikitabobko.github.io/AeroSpace/commands#mode
            enter = "mode main";

            # See: https://nikitabobko.github.io/AeroSpace/commands#mode
            esc = "mode main";
          };

          # 'service' binding mode declaration.
          # See: https://nikitabobko.github.io/AeroSpace/guide#binding-modes
          service.binding = {
            esc = [
              "reload-config"
              "mode main"
            ];

            # reset layout
            r = [
              "flatten-workspace-tree"
              "mode main"
            ];

            # Toggle between floating and tiling layout
            f = [
              "layout floating tiling"
              "mode main"
            ];

            backspace = [
              "close-all-windows-but-current"
              "mode main"
            ];

            alt-shift-n = [
              "join-with left"
              "mode main"
            ];

            alt-shift-e = [
              "join-with down"
              "mode main"
            ];

            alt-shift-i = [
              "join-with up"
              "mode main"
            ];

            alt-shift-o = [
              "join-with right"
              "mode main"
            ];
          };
        };
      };
    };

    system.defaults = {
      # See: https://nikitabobko.github.io/AeroSpace/guide#a-note-on-displays-have-separate-spaces
      spaces.spans-displays = true;

      # See: https://nikitabobko.github.io/AeroSpace/guide#a-note-on-mission-control
      # For some reason, mission control doesn’t like that AeroSpace puts a lot
      # of windows in the bottom right corner of the screen. Mission control
      # shows windows too small even when there is enough space to show them
      # bigger. There is a workaround. You can enable Group windows by
      # application setting. For whatever weird reason, it helps.
      dock.expose-group-apps = true;
    };
  };
}
