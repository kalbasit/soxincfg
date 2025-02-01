{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) optionals;
in
{
  imports = [ ./home-kubernetes-client.nix ];

  # programs
  programs.bat.enable = true;
  programs.direnv.enable = true;

  # files
  home.file = {
    ".npmrc".text = "prefix=${config.home.homeDirectory}/.filesystem";
  };

  home.packages =
    with pkgs;
    [
      amazon-ecr-credential-helper
      arduino-cli
      audacity
      awscli2
      binutils # for strings
      bitwarden-cli
      # TODO: build is failing on darwin because the dependency python3.11-agate-dbf-0.2.3 is failing.
      #csvkit
      devbox
      docker-credential-gcr
      dosbox
      duf # du replacement on steroids
      eternal-terminal
      file
      fx # JSON viewer
      gh # GitHub command line client
      gist
      git-quick-stats
      gnugrep
      gnupg
      go
      graphite-cli
      hexyl # hex viewer with nice colors
      imagemagick # for convert
      inetutils # for telnet
      jq
      jrnl
      killall
      lastpass-cli
      lazygit
      lf # curses-based file manager
      libnotify
      mercurial
      nix-index
      nixpkgs-review
      nix-zsh-completions
      nixos-generators
      nur.repos.kalbasit.nixify
      nur.repos.kalbasit.swm
      obsidian
      pv # generic progress of data through a pipeline
      scrcpy # mirror Android device via USB
      screen # needed to open up terminal devices
      signal-cli
      sqlitebrowser # graphical sqlite3 client
      todoist
      unzip
      weechat
      xsel
    ]
    ++ (optionals stdenv.isLinux [
      #
      # Linux applications
      #

      (retroarch.override {
        cores = with libretro; [
          beetle-psx
          beetle-psx-hw
        ];
      })
      _2048-in-terminal
      android-studio
      android-tools
      arduino
      blender # 3d modeling software
      # TODO: Re-enable once it builds again. It depends on libarcus and it has been marked as broken.
      # cura # slicing software for 3d printers
      dnsutils # for dig
      element-desktop # Element client
      esptool
      filezilla
      gdb
      glances
      go-mtpfs
      gotop
      inotify-tools
      kdenlive # video editing
      libreoffice
      mbuffer # memory buffer within pipeline
      obs-studio # video recording
      protonvpn-gui
      quickemu
      remmina
      slack
      smartmontools
      synology-drive-client
      vlc
      whatsapp-for-linux
      xfce.thunar
      xfce.thunar-archive-plugin
      xfce.thunar-media-tags-plugin
      xfce.thunar-volman
      xfce.tumbler
      xkb-switch # Switch your X keyboard layouts from the command line
      zoom-us
    ]);
}
