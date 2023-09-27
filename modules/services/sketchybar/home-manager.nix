{ config, lib, pkgs, ... }:

let
  inherit (lib)
    makeBinPath
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

  app-font-version = "1.0.16";

  app-font-ttf = pkgs.stdenvNoCC.mkDerivation {
    pname = "sketchybar-app-font-ttf";
    version = app-font-version;

    src = pkgs.fetchurl {
      url = "https://github.com/kvndrsslr/sketchybar-app-font/releases/download/v${app-font-version}/sketchybar-app-font.ttf";
      hash = "sha256-58gRCEJix9pnZEcoo6bm2zWduP0xXl3WWC6mt36SGuo=";
    };

    dontUnpack = true;

    installPhase = ''
      mkdir -p $out/share/fonts
      cp $src $out/share/fonts/sketchybar-app-font.ttf
    '';
  };

  app-font-map = pkgs.stdenvNoCC.mkDerivation {
    pname = "sketchybar-app-font-map";
    version = app-font-version;

    src = pkgs.fetchurl {
      url = "https://github.com/kvndrsslr/sketchybar-app-font/releases/download/v${app-font-version}/icon_map_fn.sh";
      hash = "sha256-Ca76M0sySWgsUJNziuFa+afetx/477mUtmuuosNZgbY";
    };

    dontUnpack = true;

    installPhase = ''
      mkdir -p $out/share/scripts
      cp $src $out/share/scripts/icon_map_fn.sh
    '';
  };

  config-dir = pkgs.stdenvNoCC.mkDerivation {
    pname = "sketchybar-config-dir";
    version = "0.0.1";
    src = ./src/config-dir;

    nativeBuildInputs = [ pkgs.makeWrapper ];

    installPhase = ''
      runHook preInstall

      mkdir -p $out/share/sketchybar
      cp -r * $out/share/sketchybar

      runHook postInstall
    '';

    postInstall = ''
      find $out/share/sketchybar -name '*.sh' -print0 | while read -d $'\0' file; do
        # do not wrap binaries that are not executable
        test -x "$file" || continue

        wrapProgram "$file" \
          --set CONFIG_DIR $out/share/sketchybar \
          --set PLUGIN_DIR $out/share/sketchybar/plugins \
          --set APP_FONT_MAP ${app-font-map}/share/scripts/icon_map_fn.sh \
          --prefix PATH ":" ${makeBinPath [ pkgs.gh pkgs.gnugrep pkgs.jq ]} \
          --suffix PATH ":" /opt/homebrew/bin
      done
    '';
  };
in
{
  config = mkIf cfg.enable {
    home.packages = [
      pkgs.gh
      pkgs.gnugrep
      pkgs.jq
    ];

    home.activation.sketchybar = lib.hm.dag.entryBefore [ "onFilesChange" ] ''
      mkdir -p ${config.home.homeDirectory}/Library/Fonts

      rm -f ${config.home.homeDirectory}/Library/Fonts/sketchybar-app-font.ttf
      cp ${app-font-ttf}/share/fonts/sketchybar-app-font.ttf \
        ${config.home.homeDirectory}/Library/Fonts/sketchybar-app-font.ttf
    '';

    xdg.configFile."sketchybar/sketchybarrc" = {
      executable = true;

      onChange = "brew services restart sketchybar";

      text = ''
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
