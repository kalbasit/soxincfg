{ config, lib, pkgs, ... }:

let
  inherit (lib)
    optionals
    ;
in
{
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
    csvkit
    docker-credential-gcr
    dosbox
    duf # du replacement on steroids
    element-desktop # Element client
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

    (retroarch.override { cores = with libretro; [ beetle-psx beetle-psx-hw beetle-snes ]; })
    _2048-in-terminal
    android-studio
    android-tools
    arduino
    blender # 3d modeling software
    cura # slicing software for 3d printers
    dnsutils # for dig
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
    protonvpn-cli
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

