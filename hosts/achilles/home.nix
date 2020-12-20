# home-manager configuration for user `yl`
{ soxincfg }:
{ config, pkgs, home-manager, lib, ... }:

with lib;

{
  imports = [
    soxincfg.nixosModules.profiles.workstation
  ];

  soxincfg = {
    programs = {
      starship.enable = true;
    };
  };

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

    };

    programs = {
      autorandr.enable = true;
      htop.enable = true;
      keybase.enable = true;
      keybase.enableFs = true;
      less.enable = true;
      mosh.enable = true;
      pet.enable = true;
      rofi.enable = true;
      ssh.enable = true;
      termite.enable = true;
      urxvt.enable = true;
      zsh.enable = true;
    };
  };

  # HiDPI
  soxin.programs.rofi.dpi = 196;
  xsession.pointerCursor = {
    package = pkgs.vanilla-dmz;
    name = "Vanilla-DMZ";
    size = 128;
  };
  soxin.services.xserver.windowManager.bar = {
    dpi = 196;
    height = 43;
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

      ".npmrc".text = "prefix=${config.home.homeDirectory}/.filesystem";

      ".gnupg/gpg.conf".text = ''
        # NOTE: https://github.com/jclement/dotfiles/blob/master/other/gpg.conf
        #
        # This is an implementation of the Riseup OpenPGP Best Practices
        # https://help.riseup.net/en/security/message-security/openpgp/best-practices
        #

        #-----------------------------
        # default key
        #-----------------------------

        # The default key to sign with. If this option is not used, the default key is
        # the first key found in the secret keyring

        default-key 0x7ED8B6DE75BADCF9

        #-----------------------------
        # behavior
        #-----------------------------

        # Disable inclusion of the version string in ASCII armored output
        no-emit-version

        # Disable comment string in clear text signatures and ASCII armored messages
        no-comments

        # Disable auto-starting the agent. On hosts that I'm using the GnuPG, I'd like
        # to have home-manager start the agent on login.
        no-autostart

        # Display long key IDs
        keyid-format 0xlong

        # List all keys (or the specified ones) along with their fingerprints
        with-fingerprint

        # Display the calculated validity of user IDs during key listings
        list-options show-uid-validity
        verify-options show-uid-validity

        #-----------------------------
        # keyserver
        #-----------------------------

        # This is the server that --recv-keys, --send-keys, and --search-keys will
        # communicate with to receive keys from, send keys to, and search for keys on
        keyserver hkps://hkps.pool.sks-keyservers.net

        # When using --refresh-keys, if the key in question has a preferred keyserver
        # URL, then disable use of that preferred keyserver to refresh the key from
        keyserver-options no-honor-keyserver-url

        # When searching for a key with --search-keys, include keys that are marked on
        # the keyserver as revoked
        keyserver-options include-revoked

        #-----------------------------
        # algorithm and ciphers
        #-----------------------------

        # list of personal digest preferences. When multiple digests are supported by
        # all recipients, choose the strongest one
        personal-cipher-preferences AES256 AES192 AES CAST5

        # list of personal digest preferences. When multiple ciphers are supported by
        # all recipients, choose the strongest one
        personal-digest-preferences SHA512 SHA384 SHA256 SHA224

        # message digest algorithm used when signing a key
        cert-digest-algo SHA512

        # This preference list is used for new keys and becomes the default for
        # "setpref" in the edit menu
        default-preference-list SHA512 SHA384 SHA256 SHA224 AES256 AES192 AES CAST5 ZLIB BZIP2 ZIP Uncompressed
      '';
    };

  home.packages = with pkgs; [
    nur.repos.kalbasit.rbrowser

    remmina

    weechat

    xsel

    # zoom for meetings
    zoom-us

    amazon-ecr-credential-helper
    docker-credential-gcr

    browsh

    gist

    gnupg

    go

    jq

    jrnl

    killall

    lastpass-cli

    mercurial

    mosh

    nur.repos.kalbasit.nixify

    nix-index

    nixops

    # curses-based file manager
    lf

    nur.repos.kalbasit.swm

    corgi
    vgo2nix

    unzip

    nix-zsh-completions
  ] ++ (optionals stdenv.isLinux [
    #
    # Linux applications
    #

    # XXX: Failing to compile on Darwin
    gotop

    jetbrains.idea-community

    keybase

    slack

    # Games
    _2048-in-terminal
  ]);
}
