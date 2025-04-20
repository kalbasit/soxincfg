{
  config,
  pkgs,
  ...
}:

{
  config = {
    environment.systemPackages = [
      pkgs.iina
    ];

    homebrew = {
      enable = true;

      brews = [ ];

      casks = [
        "alfred" # spotlight replacement
        "arc" # Arc Browser
        "charles"
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
          mouse-over-hilite-stack = true;

          # Set the icon size of Dock items to 36 pixels
          tilesize = 36;

          # Change minimize/maximize window effect
          mineffect = "scale";

          # Minimize windows into their application’s icon
          minimize-to-application = true;

          # Enable spring loading for all Dock items
          enable-spring-load-actions-on-all-items = true;

          # Show indicator lights for open applications in the Dock
          show-process-indicators = true;

          # Don’t animate opening applications from the Dock
          launchanim = false;

          # Speed up Mission Control animations
          expose-animation-duration = 0.1;

          # Don’t group windows by application in Mission Control
          # (i.e. use the old Exposé behavior instead)
          expose-group-apps = false;

          # Don’t show Dashboard as a Space
          dashboard-in-overlay = true;

          # Don’t automatically rearrange Spaces based on most recent use
          mru-spaces = false;

          # Remove the auto-hiding Dock delay
          autohide-delay = 0.0;
          # Remove the animation when hiding/showing the Dock
          autohide-time-modifier = 0.0;

          # Automatically hide and show the Dock
          autohide = true;

          # Make Dock icons of hidden applications translucent
          showhidden = true;

          # Don’t show recent applications in Dock
          show-recents = false;

          # disable all hot corners
          wvous-bl-corner = 1;
          wvous-br-corner = 1;
          wvous-tl-corner = 1;
          wvous-tr-corner = 1;
        };

        finder = {
          # Finder: allow quitting via ⌘ + Q; doing so will also hide desktop icons
          QuitMenuItem = true;

          # Display full POSIX path as Finder window title
          _FXShowPosixPathInTitle = true;

          # Disable the warning when changing a file extension
          FXEnableExtensionChangeWarning = false;

          # Do not show any items on the Desktop
          ShowExternalHardDrivesOnDesktop = false;
          ShowHardDrivesOnDesktop = false;
          ShowRemovableMediaOnDesktop = false;
          ShowMountedServersOnDesktop = false;

          # Show path breadcrumbs on path bar
          ShowPathbar = true;

          # Show status bar at the bottom of finder windows
          ShowStatusBar = true;

          # Keep folders on top when sorting by name
          _FXSortFoldersFirst = true;

          # Default the current search scope to current folder not this mac
          FXDefaultSearchScope = "SCcf";
        };

        # Disable the “Are you sure you want to open this application?” dialog
        LaunchServices.LSQuarantine = false;

        # Show the clock in 24 hours format
        menuExtraClock.Show24Hour = true;

        NSGlobalDomain = {
          # Enable “natural” (Lion-style) scrolling (mths.be/macos disables it)
          "com.apple.swipescrolldirection" = true;

          # Set sidebar icon size to medium
          NSTableViewDefaultSizeMode = 2;

          # Force clock to be 24-hours
          AppleICUForce24HourTime = true;

          # Always show scrollbars
          AppleShowScrollBars = "Always";

          # Metric everywhere
          AppleMeasurementUnits = "Centimeters";
          AppleMetricUnits = 1;
          AppleTemperatureUnit = "Celsius";

          # Disable the over-the-top focus ring animation
          NSUseAnimatedFocusRing = false;

          # Increase window resize speed for Cocoa applications
          NSWindowResizeTime = 1.0e-3;

          # Expand save panel by default
          NSNavPanelExpandedStateForSaveMode = true;
          NSNavPanelExpandedStateForSaveMode2 = true;

          # Expand print panel by default
          PMPrintingExpandedStateForPrint = true;
          PMPrintingExpandedStateForPrint2 = true;

          # Save to disk (not to iCloud) by default
          NSDocumentSaveNewDocumentsToCloud = false;

          # Display ASCII control characters using caret notation in standard text views
          # Try e.g. `cd /tmp; unidecode "\x{0000}" > cc.txt; open -e cc.txt`
          NSTextShowsControlCharacters = true;

          # Disable automatic termination of inactive apps
          NSDisableAutomaticTermination = true;

          # Override the keyboard repeat rate to something more sensible.
          KeyRepeat = 2;
          InitialKeyRepeat = 15;

          # Disable automatic capitalization as it’s annoying when typing code
          NSAutomaticCapitalizationEnabled = false;

          # Disable smart dashes as they’re annoying when typing code
          NSAutomaticDashSubstitutionEnabled = false;

          # Disable automatic period substitution as it’s annoying when typing code
          NSAutomaticPeriodSubstitutionEnabled = false;

          # Disable smart quotes as they’re annoying when typing code
          NSAutomaticQuoteSubstitutionEnabled = false;

          # Disable auto-correct
          NSAutomaticSpellingCorrectionEnabled = false;

          # Enable subpixel font rendering on non-Apple LCDs
          # Reference: https://github.com/kevinSuttle/macOS-Defaults/issues/17#issuecomment-266633501
          AppleFontSmoothing = 1;

          # Enable full keyboard access for all controls
          # (e.g. enable Tab in modal dialogs)
          AppleKeyboardUIMode = 3;

          # Disable press-and-hold for keys in favor of key repeat
          ApplePressAndHoldEnabled = false;

          # Finder: show all filename extensions
          AppleShowAllExtensions = true;

          # Enable spring loading for directories
          "com.apple.springing.enabled" = true;

          # Remove the spring loading delay for directories
          "com.apple.springing.delay" = 0.0;
        };

        screencapture.location = "${config.users.users.wnasreddine.home}/Pictures/Screenshots";

        trackpad = {
          # Trackpad: enable tap to click
          Clicking = true;

          # Trackpad: enable three-finger drag
          TrackpadThreeFingerDrag = true;

          # Trackpad: enable right click on the bottom right of the trackpad
          TrackpadRightClick = true;
        };

        WindowManager = {
          # Hide all items from Desktop
          StandardHideDesktopIcons = true;
        };
      };

      keyboard = {
        # Remap CapsLock to Control
        enableKeyMapping = true;
        remapCapsLockToControl = true;
      };
    };
  };
}
