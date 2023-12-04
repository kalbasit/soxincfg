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
    dnsutils # for dig
    screen
    docker-credential-gcr
    duf # du replacement on steroids
    ncdu
    file
    fx # JSON viewer
    gdb
    gh
    gist
    git-quick-stats
    gnupg
    jq
    killall
    lf # curses-based file manager
    mercurial
    nix-index
    nixpkgs-review
    nix-zsh-completions
    unzip
  ] ++ (optionals stdenv.isLinux [
    #
    # Linux applications
    #

    glances
    gotop
    protonvpn-cli
  ]);
}
