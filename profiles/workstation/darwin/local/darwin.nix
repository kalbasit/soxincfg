{
  config,
  pkgs,
  lib,
  ...
}:

{
  config = {
    environment.systemPackages = [
      pkgs.keka
      pkgs.iina
    ];

    homebrew = {
      enable = true;

      brews = [ ];

      casks = [
        "alfred" # spotlight replacement
        "antigravity" # Google's AI Editor
        "arc" # Arc Browser
        "charles"
        "claude"
        "claude-code"
        "dbeaver-community" # Database GUI
        "displaylink" # software to drive the USB-C hub
        "font-0xproto-nerd-font" # Nerd font
        "istat-menus"
        "keybase"
        "postman" # API
      ];
    };

    system = {
      defaults = {
        dock = {
          # Enable highlight hover effect for the grid view of a stack (Dock)
          mouse-over-hilite-stack = lib.mkDefault true;

          # Set the icon size of Dock items to 36 pixels
          tilesize = lib.mkDefault 36;

          # Change minimize/maximize window effect
          mineffect = lib.mkDefault "scale";

          # Minimize windows into their application’s icon
          minimize-to-application = lib.mkDefault true;

          # Enable spring loading for all Dock items
          enable-spring-load-actions-on-all-items = lib.mkDefault true;

          # Show indicator lights for open applications in the Dock
          show-process-indicators = lib.mkDefault true;

          # Don’t animate opening applications from the Dock
          launchanim = lib.mkDefault false;

          # Speed up Mission Control animations
          expose-animation-duration = lib.mkDefault 0.1;

          # Don’t group windows by application in Mission Control
          # (i.e. use the old Exposé behavior instead)
          expose-group-apps = lib.mkDefault false;

          # Don’t show Dashboard as a Space
          dashboard-in-overlay = lib.mkDefault true;

          # Don’t automatically rearrange Spaces based on most recent use
          mru-spaces = lib.mkDefault false;

          # Remove the auto-hiding Dock delay
          autohide-delay = lib.mkDefault 0.0;
          # Remove the animation when hiding/showing the Dock
          autohide-time-modifier = lib.mkDefault 0.0;

          # Automatically hide and show the Dock
          autohide = lib.mkDefault true;

          # Make Dock icons of hidden applications translucent
          showhidden = lib.mkDefault true;

          # Don’t show recent applications in Dock
          show-recents = lib.mkDefault false;

          # disable all hot corners
          wvous-bl-corner = lib.mkDefault 1;
          wvous-br-corner = lib.mkDefault 1;
          wvous-tl-corner = lib.mkDefault 1;
          wvous-tr-corner = lib.mkDefault 1;
        };

        finder = {
          # Finder: allow quitting via ⌘ + Q; doing so will also hide desktop icons
          QuitMenuItem = lib.mkDefault true;

          # Display full POSIX path as Finder window title
          _FXShowPosixPathInTitle = lib.mkDefault true;

          # Disable the warning when changing a file extension
          FXEnableExtensionChangeWarning = lib.mkDefault false;

          # Do not show any items on the Desktop
          ShowExternalHardDrivesOnDesktop = lib.mkDefault false;
          ShowHardDrivesOnDesktop = lib.mkDefault false;
          ShowRemovableMediaOnDesktop = lib.mkDefault false;
          ShowMountedServersOnDesktop = lib.mkDefault false;

          # Show path breadcrumbs on path bar
          ShowPathbar = lib.mkDefault true;

          # Show status bar at the bottom of finder windows
          ShowStatusBar = lib.mkDefault true;

          # Keep folders on top when sorting by name
          _FXSortFoldersFirst = lib.mkDefault true;

          # Default the current search scope to current folder not this mac
          FXDefaultSearchScope = lib.mkDefault "SCcf";
        };

        # Disable the “Are you sure you want to open this application?” dialog
        LaunchServices.LSQuarantine = lib.mkDefault false;

        # Show the clock in 24 hours format
        menuExtraClock.Show24Hour = lib.mkDefault true;

        NSGlobalDomain = {
          # Enable “natural” (Lion-style) scrolling (mths.be/macos disables it)
          "com.apple.swipescrolldirection" = lib.mkDefault true;

          # Set sidebar icon size to medium
          NSTableViewDefaultSizeMode = lib.mkDefault 2;

          # Force clock to be 24-hours
          AppleICUForce24HourTime = lib.mkDefault true;

          # Always show scrollbars
          AppleShowScrollBars = lib.mkDefault "Always";

          # Metric everywhere
          AppleMeasurementUnits = lib.mkDefault "Centimeters";
          AppleMetricUnits = lib.mkDefault 1;
          AppleTemperatureUnit = lib.mkDefault "Celsius";

          # Disable the over-the-top focus ring animation
          NSUseAnimatedFocusRing = lib.mkDefault false;

          # Increase window resize speed for Cocoa applications
          NSWindowResizeTime = lib.mkDefault 1.0e-3;

          # Expand save panel by default
          NSNavPanelExpandedStateForSaveMode = lib.mkDefault true;
          NSNavPanelExpandedStateForSaveMode2 = lib.mkDefault true;

          # Expand print panel by default
          PMPrintingExpandedStateForPrint = lib.mkDefault true;
          PMPrintingExpandedStateForPrint2 = lib.mkDefault true;

          # Save to disk (not to iCloud) by default
          NSDocumentSaveNewDocumentsToCloud = lib.mkDefault false;

          # Display ASCII control characters using caret notation in standard text views
          # Try e.g. `cd /tmp; unidecode "\x{0000}" > cc.txt; open -e cc.txt`
          NSTextShowsControlCharacters = lib.mkDefault true;

          # Disable automatic termination of inactive apps
          NSDisableAutomaticTermination = lib.mkDefault true;

          # Override the keyboard repeat rate to something more sensible.
          KeyRepeat = lib.mkDefault 2;
          InitialKeyRepeat = lib.mkDefault 15;

          # Disable automatic capitalization as it’s annoying when typing code
          NSAutomaticCapitalizationEnabled = lib.mkDefault false;

          # Disable smart dashes as they’re annoying when typing code
          NSAutomaticDashSubstitutionEnabled = lib.mkDefault false;

          # Disable automatic period substitution as it’s annoying when typing code
          NSAutomaticPeriodSubstitutionEnabled = lib.mkDefault false;

          # Disable smart quotes as they’re annoying when typing code
          NSAutomaticQuoteSubstitutionEnabled = lib.mkDefault false;

          # Disable auto-correct
          NSAutomaticSpellingCorrectionEnabled = lib.mkDefault false;

          # Enable subpixel font rendering on non-Apple LCDs
          # Reference: https://github.com/kevinSuttle/macOS-Defaults/issues/17#issuecomment-266633501
          AppleFontSmoothing = lib.mkDefault 1;

          # Enable full keyboard access for all controls
          # (e.g. enable Tab in modal dialogs)
          AppleKeyboardUIMode = lib.mkDefault 3;

          # Disable press-and-hold for keys in favor of key repeat
          ApplePressAndHoldEnabled = lib.mkDefault false;

          # Finder: show all filename extensions
          AppleShowAllExtensions = lib.mkDefault true;

          # Enable spring loading for directories
          "com.apple.springing.enabled" = lib.mkDefault true;

          # Remove the spring loading delay for directories
          "com.apple.springing.delay" = lib.mkDefault 0.0;
        };

        screencapture.location = lib.mkDefault "${config.users.users.wnasreddine.home}/Pictures/Screenshots";

        trackpad = {
          # Trackpad: enable tap to click
          Clicking = lib.mkDefault true;

          # Trackpad: enable three-finger drag
          TrackpadThreeFingerDrag = lib.mkDefault true;

          # Trackpad: enable right click on the bottom right of the trackpad
          TrackpadRightClick = lib.mkDefault true;
        };

        WindowManager = {
          # Hide all items from Desktop
          StandardHideDesktopIcons = lib.mkDefault true;
        };
      };

      keyboard = {
        # Remap CapsLock to Control
        enableKeyMapping = lib.mkDefault true;
        remapCapsLockToControl = lib.mkDefault true;
      };
    };
  };
}
