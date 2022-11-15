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
    binutils # for strings
    bitwarden-cli
    docker-credential-gcr
    dosbox
    duf # du replacement on steroids
    eternal-terminal
    file
    fx # JSON viewer
    gdb
    gh # GitHub command line client
    gist
    git-quick-stats
    gnupg
    go
    hexyl # hex viewer with nice colors
    imagemagick # for convert
    jq
    jrnl
    killall
    lastpass-cli
    lazygit
    lf # curses-based file manager
    libnotify
    mercurial
    nix-index
    nix-review
    nix-zsh-completions
    nur.repos.kalbasit.nixify
    nur.repos.kalbasit.swm
    obsidian
    signal-cli
    todoist
    unzip
    vgo2nix
    weechat
    synology-drive-client
    xsel
  ] ++ (optionals stdenv.isLinux [
    #
    # Linux applications
    #

    (retroarch.override { cores = with libretro; [ beetle-psx beetle-psx-hw beetle-snes ]; })
    _2048-in-terminal
    arduino
    blender # 3d modeling software
    cura # slicing software for 3d printers
    dnsutils # for dig
    esptool
    filezilla
    glances
    gotop
    jetbrains.goland
    jetbrains.idea-ultimate
    jetbrains.ruby-mine
    kdenlive # video editing
    libreoffice
    obs-studio # video recording
    protonvpn-cli
    remmina
    slack
    smartmontools
    teams
    todoist-electron
    go-mtpfs
    xkb-switch # Switch your X keyboard layouts from the command line
    zoom-us
  ]);
}

