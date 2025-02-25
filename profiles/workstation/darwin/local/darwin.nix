{
  config = {
    homebrew = {
      enable = true;

      brews = [ ];

      casks = [
        "alfred" # spotlight replacement
        "arc" # Arc Browser
        "charles"
        "dbeaver-community" # Database GUI
        "discord"
        "dosbox" # MS-DOS game emulator
        "flotato" # Makes applications of any website.
        "gimp"
        "goland"
        "google-chrome"
        "homebrew/cask-fonts/font-sf-pro" # SF Pro used by SketchyBar
        "iterm2"
        "keybase"
        "postico" # Yet another GUI for Postgres
        "postman" # API
        "raycast" # Alfred replacement
        "rectangle" # macOS window manager
        "sequel-pro" # MySQL frontend supporting connections through a tunnel
        "signal"
        "slack"
        "synology-drive"
        "tailscale"
        "viscosity" # VPN Application
        "vlc"
        "whatsapp" # WhatsApp application
        "zoom"
      ];

      taps = [ "homebrew/cask-fonts" ];
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
        };

        finder = {
          # Finder: allow quitting via ⌘ + Q; doing so will also hide desktop icons
          QuitMenuItem = true;

          # Display full POSIX path as Finder window title
          _FXShowPosixPathInTitle = true;

          # Disable the warning when changing a file extension
          FXEnableExtensionChangeWarning = false;
        };

        NSGlobalDomain = {
          # Enable “natural” (Lion-style) scrolling (mths.be/macos disables it)
          "com.apple.swipescrolldirection" = true;

          # Set sidebar icon size to medium
          NSTableViewDefaultSizeMode = 2;

          # Always show scrollbars
          AppleShowScrollBars = "Always";

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

        trackpad = {
          # Trackpad: enable tap to click
          Clicking = true;

          # Trackpad: enable three-finger drag
          TrackpadThreeFingerDrag = true;

          # Trackpad: enable right click on the bottom right of the trackpad
          TrackpadRightClick = true;
        };

        # Disable the “Are you sure you want to open this application?” dialog
        LaunchServices.LSQuarantine = false;

        # Save screenshots to the desktop
        screencapture.location = "$HOME/Desktop";

      };

      keyboard = {
        # Remap CapsLock to Control
        enableKeyMapping = true;
        remapCapsLockToControl = true;
      };

      # TODO: Rewrite as much of these as possible using nix-darwin
      activationScripts.postActivation.text = ''
        # From https://github.com/mathiasbynens/dotfiles/blob/master/.macos taken
        # at commit e72d1060f3df8c157f93af52ea59508dae36ef50.

        ###############################################################################
        # General UI/UX                                                               #
        ###############################################################################

        # Set standby delay to 24 hours (default is 1 hour)
        # sudo pmset -a standbydelay 86400

        # Disable the sound effects on boot
        sudo nvram SystemAudioVolume=" "

        # Disable transparency in the menu bar and elsewhere on Yosemite
        defaults write com.apple.universalaccess reduceTransparency -bool true

        # Set highlight color to green
        defaults write NSGlobalDomain AppleHighlightColor -string "0.764700 0.976500 0.568600"

        # Automatically quit printer app once the print jobs complete
        defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

        # Remove duplicates in the “Open With” menu (also see `lscleanup` alias)
        /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user

        # Disable Resume system-wide
        # defaults write com.apple.systempreferences NSQuitAlwaysKeepsWindows -bool false

        # Set Help Viewer windows to non-floating mode
        defaults write com.apple.helpviewer DevMode -bool true

        # Reveal IP address, hostname, OS version, etc. when clicking the clock
        # in the login window
        sudo defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName

        # Restart automatically if the computer freezes
        sudo systemsetup -setrestartfreeze on

        # Never go into computer sleep mode
        # sudo systemsetup -setcomputersleep Off > /dev/null

        # Disable Notification Center and remove the menu bar icon
        # launchctl unload -w /System/Library/LaunchAgents/com.apple.notificationcenterui.plist 2> /dev/null

        ###############################################################################
        # SSD-specific tweaks                                                         #
        ###############################################################################

        # Disable hibernation (speeds up entering sleep mode)
        # sudo pmset -a hibernatemode 0

        ###############################################################################
        # Trackpad, mouse, keyboard, Bluetooth accessories, and input                 #
        ###############################################################################

        # Increase sound quality for Bluetooth headphones/headsets
        # defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" -int 40

        # Use scroll gesture with the Ctrl (^) modifier key to zoom
        defaults write com.apple.universalaccess closeViewScrollWheelToggle -bool true
        defaults write com.apple.universalaccess HIDScrollZoomModifierMask -int 262144
        # Follow the keyboard focus while zoomed in
        defaults write com.apple.universalaccess closeViewZoomFollowsFocus -bool true

        # Show language menu in the top right corner of the boot screen
        sudo defaults write /Library/Preferences/com.apple.loginwindow showInputMenu -bool true

        # Set language and text formats
        # Note: if you’re in the US, replace `EUR` with `USD`, `Centimeters` with
        # `Inches`, `en_GB` with `en_US`, and `true` with `false`.
        defaults write NSGlobalDomain AppleLanguages -array "en"
        defaults write NSGlobalDomain AppleLocale -string "en_US@currency=US"
        defaults write NSGlobalDomain AppleMeasurementUnits -string "Centimeters"
        defaults write NSGlobalDomain AppleMetricUnits -bool true

        # Stop iTunes from responding to the keyboard media keys
        # launchctl unload -w /System/Library/LaunchAgents/com.apple.rcd.plist 2>/dev/null

        ###############################################################################
        # Screen                                                                      #
        ###############################################################################

        # Require password immediately after sleep or screen saver begins
        # defaults write com.apple.screensaver askForPassword -int 1
        # defaults write com.apple.screensaver askForPasswordDelay -int 0

        # Save screenshots in PNG format (other options: BMP, GIF, JPG, PDF, TIFF)
        defaults write com.apple.screencapture type -string "png"

        # Disable shadow in screenshots
        defaults write com.apple.screencapture disable-shadow -bool true

        # Enable HiDPI display modes (requires restart)
        # sudo defaults write /Library/Preferences/com.apple.windowserver DisplayResolutionEnabled -bool true

        ###############################################################################
        # Finder                                                                      #
        ###############################################################################

        # Finder: disable window animations and Get Info animations
        defaults write com.apple.finder DisableAllAnimations -bool true

        # Set Desktop as the default location for new Finder windows
        # For other paths, use `PfLo` and `file:///full/path/here/`
        # defaults write com.apple.finder NewWindowTarget -string "PfDe"
        # defaults write com.apple.finder NewWindowTargetPath -string "file://$HOME/Desktop/"

        # Show icons for hard drives, servers, and removable media on the desktop
        defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
        defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true
        defaults write com.apple.finder ShowMountedServersOnDesktop -bool true
        defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true

        # Finder: show status bar
        defaults write com.apple.finder ShowStatusBar -bool true

        # Finder: show path bar
        defaults write com.apple.finder ShowPathbar -bool true

        # Keep folders on top when sorting by name
        defaults write com.apple.finder _FXSortFoldersFirst -bool true

        # When performing a search, search the current folder by default
        defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

        # Avoid creating .DS_Store files on network or USB volumes
        defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
        defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

        # Disable disk image verification
        # defaults write com.apple.frameworks.diskimages skip-verify -bool true
        # defaults write com.apple.frameworks.diskimages skip-verify-locked -bool true
        # defaults write com.apple.frameworks.diskimages skip-verify-remote -bool true

        # Automatically open a new Finder window when a volume is mounted
        defaults write com.apple.frameworks.diskimages auto-open-ro-root -bool true
        defaults write com.apple.frameworks.diskimages auto-open-rw-root -bool true
        defaults write com.apple.finder OpenWindowForNewRemovableDisk -bool true

        # Use list view in all Finder windows by default
        # Four-letter codes for the other view modes: `icnv`, `clmv`, `Flwv`
        defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

        # Disable the warning before emptying the Trash
        defaults write com.apple.finder WarnOnEmptyTrash -bool false

        # Enable AirDrop over Ethernet and on unsupported Macs running Lion
        # defaults write com.apple.NetworkBrowser BrowseAllInterfaces -bool true

        # Show the ~/Library folder
        chflags nohidden ~/Library

        # Show the /Volumes folder
        sudo chflags nohidden /Volumes

        # Expand the following File Info panes:
        # “General”, “Open with”, and “Sharing & Permissions”
        defaults write com.apple.finder FXInfoPanesExpanded -dict \
          General -bool true \
          OpenWith -bool true \
          Privileges -bool true

        ###############################################################################
        # Dock, Dashboard, and hot corners                                            #
        ###############################################################################

        # Disable Dashboard
        # defaults write com.apple.dashboard mcx-disabled -bool true

        # Hot corners
        # Possible values:
        #  0: no-op
        #  2: Mission Control
        #  3: Show application windows
        #  4: Desktop
        #  5: Start screen saver
        #  6: Disable screen saver
        #  7: Dashboard
        # 10: Put display to sleep
        # 11: Launchpad
        # 12: Notification Center
        # Top left screen corner → Mission Control
        defaults write com.apple.dock wvous-tl-corner -int 2
        defaults write com.apple.dock wvous-tl-modifier -int 0
        # Top right screen corner → Desktop
        defaults write com.apple.dock wvous-tr-corner -int 4
        defaults write com.apple.dock wvous-tr-modifier -int 0
        # Bottom left screen corner → Start screen saver
        defaults write com.apple.dock wvous-bl-corner -int 5
        defaults write com.apple.dock wvous-bl-modifier -int 0
      '';
    };
  };
}
