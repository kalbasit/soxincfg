{ config, lib, pkgs, ... }:

let
  inherit (lib)
    optionals
    ;
in
{
  imports = [
    ./home-kubernetes-client.nix
  ];

  # programs
  programs.bat.enable = true;
  programs.direnv.enable = true;

  # files
  home.file = {
    ".npmrc".text = "prefix=${config.home.homeDirectory}/.filesystem";
  };

  home.packages = with pkgs; [
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
    scrcpy # mirror Android device via USB
    screen # needed to open up terminal devices
    signal-cli
    todoist
    unzip
    weechat
    xsel
  ] ++ (optionals stdenv.isLinux [
    #
    # Linux applications
    #

    (retroarch.override { cores = with libretro; [ beetle-psx beetle-psx-hw ]; })
    _2048-in-terminal
    android-studio
    android-tools
    arduino
    blender # 3d modeling software
    cura # slicing software for 3d printers
    dnsutils # for dig
    element-desktop # Element client
    esptool
    filezilla
    gdb
    glances
    gotop
    inotify-tools
    # jetbrains.goland
    # jetbrains.idea-ultimate
    # jetbrains.ruby-mine
    kdenlive # video editing
    libreoffice
    obs-studio # video recording
    protonvpn-gui
    quickemu
    remmina
    synology-drive-client
    slack
    smartmontools
    xfce.thunar
    xfce.thunar-volman
    xfce.thunar-archive-plugin
    xfce.thunar-media-tags-plugin
    # teams
    # todoist-electron
    go-mtpfs
    whatsapp-for-linux
    xkb-switch # Switch your X keyboard layouts from the command line
    zoom-us
  ]);
}

