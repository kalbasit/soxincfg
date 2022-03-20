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

  # services
  services.clipmenu.enable = true;
  services.flameshot.enable = true;
  services.betterlockscreen = {
    enable = true;
    arguments = [
      "--show-layout"
    ];
  };

  # files
  home.file = {
    ".npmrc".text = "prefix=${config.home.homeDirectory}/.filesystem";
  };

  home.packages = with pkgs; [
    # boards
    arduino
    arduino-cli
    esptool

    # GitHub command line client
    gh

    # video recording/editing
    obs-studio
    kdenlive

    git-quick-stats

    zulip
    zulip-term

    obsidian

    todoist
    todoist-electron

    libreoffice

    cura # slicing software for 3d printers
    prusa-slicer # slicing software for 3d printers
    blender # 3d modeling software

    hexyl # hex viewer with nice colors
    duf # du replacement on steroids
    fx # JSON viewer

    # Switch your X keyboard layouts from the command line
    xkb-switch

    remmina

    file

    dnsutils # for dig

    dosbox
    (retroarch.override {
      cores = with libretro; [
        beetle-psx
        beetle-psx-hw
        beetle-snes
      ];
    })

    imagemagick # for convert

    binutils # for strings

    weechat

    xsel

    eternal-terminal

    # zoom for meetings
    zoom-us

    libnotify

    amazon-ecr-credential-helper
    docker-credential-gcr

    filezilla

    bitwarden-cli

    gdb

    gist

    gnupg

    go

    jq

    jrnl

    killall

    lastpass-cli

    lazygit

    mercurial

    nur.repos.kalbasit.nixify

    nix-index

    nix-review

    # curses-based file manager
    lf

    nur.repos.kalbasit.swm

    vgo2nix

    unzip

    nix-zsh-completions
  ] ++ (optionals stdenv.isLinux [
    #
    # Linux applications
    #

    vivaldi
    vivaldi-ffmpeg-codecs
    vivaldi-widevine

    # XXX: Failing to compile on Darwin
    gotop

    jetbrains.idea-ultimate
    jetbrains.goland
    bazel

    slack

    glances

    # Games
    _2048-in-terminal

    protonvpn-cli
  ]);
}
