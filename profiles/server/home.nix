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
    binutils # for strings
    bitwarden-cli
    dnsutils # for dig
    docker-credential-gcr
    duf # du replacement on steroids
    file
    fx # JSON viewer
    gdb
    gh
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
    mercurial
    nix-index
    nix-review
    nix-zsh-completions
    nur.repos.kalbasit.nixify
    nur.repos.kalbasit.swm
    unzip
  ] ++ (optionals stdenv.isLinux [
    #
    # Linux applications
    #

    _2048-in-terminal
    glances
    gotop
    protonvpn-cli
  ]);
}
