# home-manager configuration for user `yl`
{ soxincfg }:
{ config, pkgs, home-manager, ... }:

{
  imports = [
    soxincfg.nixosModules.profiles.workstation
  ];

  soxin = {
    hardware.bluetooth.enable = true;

    settings = {
      fonts.enable = true;
      gtk.enable = true;
      keyboard = {
        layouts = [
          { x11 = { layout = "us"; variant = "colemak"; }; }
        ];
      };
    };

    hardware = {
      lowbatt.enable = true;
    };

    services = {
      caffeine.enable = true;
      dunst.enable = true;
      gpgAgent.enable = true;
      locker = {
        enable = true;
        color = "ffa500";
        extraArgs = [
          "--clock"
          "--show-failed-attempts"
          "--bar-indicator"
          "--datestr='%A %Y-%m-%d'"
        ];
      };

      # HiDPI
      xserver.windowManager.bar = {
        dpi = 196;
        height = 43;
      };
    };

    programs = {
      autorandr.enable = true;
      htop.enable = true;
      keybase.enable = true;
      mosh.enable = true;
      rofi.enable = true;
      ssh.enable = true;
      starship.enable = true;
      termite.enable = true;
      urxvt.enable = true;
      zsh.enable = true;
    };
  };

  programs.bat.enable = true;
  programs.direnv.enable = true;
  services.flameshot.enable = true;

  programs.zsh.initExtra = ''
    # Set the browser to my relay browser
    export BROWSER="${pkgs.nur.repos.kalbasit.rbrowser}/bin/rbrowser"
  '';

  # TODO: I'm getting an error that home-manager is missing
  # home.activation = {
  #   rbrowser-desktop-link =
  #     let
  #       symlink = src: dst: home-manager.lib.hm.dagEntryAfter [ "installPackages" ] ''
  #         mkdir -p ${builtins.dirOf dst}
  #         ln -Tsf ${src} ${dst}
  #       '';
  #     in
  #     symlink
  #       "${pkgs.nur.repos.kalbasit.rbrowser}/share/applications/rbrowser.desktop"
  #       "${config.home.homeDirectory}/.local/share/applications/rbrowser.desktop";
  # };

  home.file =
    let
      mimeList =
        let
          mimeTypes = [
            "application/pdf"
            "application/x-extension-htm"
            "application/x-extension-html"
            "application/x-extension-shtml"
            "application/x-extension-xht"
            "application/x-extension-xhtml"
            "application/xhtml+xml"
            "text/html"
            "x-scheme-handler/about"
            "x-scheme-handler/chrome"
            "x-scheme-handler/ftp"
            "x-scheme-handler/http"
            "x-scheme-handler/https"
            "x-scheme-handler/irc"
            "x-scheme-handler/ircs"
            "x-scheme-handler/mailto"
            "x-scheme-handler/unknown"
            "x-scheme-handler/webcal"
          ];

          rbrowser = builtins.concatStringsSep
            "\n"
            (map (typ: "${typ}=rbrowser.desktop") mimeTypes);

        in
        ''
          [Default Applications]
          ${rbrowser}
        '';
    in
    {
      ".local/share/applications/mimeapps.list".text = mimeList;
      ".config/mimeapps.list".text = mimeList;

      ".config/greenclip.cfg".text = ''
        Config {
         maxHistoryLength = 250,
         historyPath = "~/.cache/greenclip.history",
         staticHistoryPath = "~/.cache/greenclip.staticHistory",
         imageCachePath = "/tmp/",
         usePrimarySelectionAsInput = False,
         blacklistedApps = [],
         trimSpaceFromSelection = True
        }
      '';
    };

  home.packages = with pkgs; [
    nur.repos.kalbasit.rbrowser

    remmina

    weechat

    xsel

    # zoom for meetings
    # TODO: it's not building
    # zoom-us
  ];
}
