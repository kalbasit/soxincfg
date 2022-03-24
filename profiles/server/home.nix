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
    gh

    git-quick-stats

    hexyl # hex viewer with nice colors
    duf # du replacement on steroids
    fx # JSON viewer

    file

    dnsutils # for dig

    imagemagick # for convert

    binutils # for strings

    amazon-ecr-credential-helper
    docker-credential-gcr

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

    # XXX: Failing to compile on Darwin
    gotop

    glances

    # Games
    _2048-in-terminal

    protonvpn-cli
  ]);
}
