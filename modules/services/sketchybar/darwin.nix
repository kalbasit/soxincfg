{ config, lib, pkgs, ... }:

let
  inherit (lib)
    mkForce
    mkIf
    ;

  cfg = config.soxincfg.services.sketchybar;

  helper = pkgs.stdenv.mkDerivation {
    pname = "sketchybar-helper";
    version = "0.0.1";
    src = ./src/helper;
    makeFlags = [ "helper" ];
    installPhase = ''
      mkdir -p $out/bin
      cp helper $out/bin/helper
    '';
  };

  config-dir = pkgs.stdenvNoCC.mkDerivation {
    pname = "sketchybar-config-dir";
    version = "0.0.1";
    src = ./src/config-dir;
    buildPhase = ''
      runHook preBuild

      find . -name '*.sh' -print0 | while read -d $'\0' file; do
        substituteInPlace "$file" \
          --subst-var-by CONFIG_DIR $out/share/sketchybar \
          --subst-var-by PLUGIN_DIR $out/share/sketchybar/plugins
      done

      runHook postBuild
    '';
    installPhase = ''
      runHook preInstall

      mkdir -p $out/share/sketchybar
      cp -r * $out/share/sketchybar

      runHook postInstall
    '';
  };
in
{
  config = mkIf cfg.enable {
    launchd.user.agents.sketchybar.serviceConfig = {
      EnvironmentVariables = {
        PATH = mkForce (builtins.concatStringsSep ":" [
          "${config.services.sketchybar.package}/bin"
          "${pkgs.gh}/bin"
          "${pkgs.gnugrep}/bin"
          "${pkgs.jq}/bin"
          "${config.environment.systemPath}"
          "/opt/homebrew/bin"
          "/usr/local/bin"
        ]);
      };
      StandardOutPath = "/var/tmp/sketchybar.stdout.log";
      StandardErrorPath = "/var/tmp/sketchybar.stderr.log";
    };

    services.sketchybar = {
      enable = true;
      config = ''
        CONFIG_DIR="${config-dir}/share/sketchybar"

        source "$CONFIG_DIR/colors.sh" # Loads all defined colors
        source "$CONFIG_DIR/icons.sh" # Loads all defined icons

        ITEM_DIR="$CONFIG_DIR/items" # Directory where the items are configured
        PLUGIN_DIR="$CONFIG_DIR/plugins" # Directory where all the plugin scripts are stored

        FONT="SF Pro" # Needs to have Regular, Bold, Semibold, Heavy and Black variants
        PADDINGS=3 # All paddings use this value (icon, label, background)

        # Setting up and starting the helper process
        HELPER=git.felix.helper
        killall helper
        ${helper}/bin/helper $HELPER > /dev/null 2>&1 &

        # Unload the macOS on screen indicator overlay for volume change
        # launchctl unload -F /System/Library/LaunchAgents/com.apple.OSDUIHelper.plist > /dev/null 2>&1 &

        # Setting up the general bar appearance of the bar
        bar=(
          height=45
          color=$BAR_COLOR
          border_width=2
          border_color=$BAR_BORDER_COLOR
          shadow=off
          position=top
          sticky=on
          padding_right=10
          padding_left=10
          y_offset=-5
          margin=-2
          topmost=window
        )

        sketchybar --bar "''${bar[@]}"

        # Setting up default values
        defaults=(
          updates=when_shown
          icon.font="$FONT:Bold:14.0"
          icon.color=$ICON_COLOR
          icon.padding_left=$PADDINGS
          icon.padding_right=$PADDINGS
          label.font="$FONT:Semibold:13.0"
          label.color=$LABEL_COLOR
          label.padding_left=$PADDINGS
          label.padding_right=$PADDINGS
          padding_right=$PADDINGS
          padding_left=$PADDINGS
          background.height=26
          background.corner_radius=9
          background.border_width=2
          popup.background.border_width=2
          popup.background.corner_radius=9
          popup.background.border_color=$POPUP_BORDER_COLOR
          popup.background.color=$POPUP_BACKGROUND_COLOR
          popup.blur_radius=20
          popup.background.shadow.drawing=on
        )

        sketchybar --default "''${defaults[@]}"

        # Left
        source "$ITEM_DIR/apple.sh"
        source "$ITEM_DIR/spaces.sh"
        source "$ITEM_DIR/yabai.sh"
        source "$ITEM_DIR/front_app.sh"

        # Center
        source "$ITEM_DIR/spotify.sh"

        # Right
        source "$ITEM_DIR/calendar.sh"
        source "$ITEM_DIR/brew.sh"
        source "$ITEM_DIR/wifi.sh"
        source "$ITEM_DIR/github.sh"
        source "$ITEM_DIR/battery.sh"
        source "$ITEM_DIR/volume.sh"
        source "$ITEM_DIR/cpu.sh"

        # Forcing all item scripts to run (never do this outside of sketchybarrc)
        sketchybar --update

        echo "sketchybar configuation loaded.."
      '';
    };
  };
}
