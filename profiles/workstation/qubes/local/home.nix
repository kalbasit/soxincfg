{ config, pkgs, lib, ... }:

let
  inherit (lib)
    optionals
    ;
in
{
  # Configure SOPS to use the gpg wrapper
  # https://github.com/getsops/sops#213specify-a-different-gpg-executable
  #home.sessionVariables."SOPS_GPG_EXEC" ="qubes-gpg-client";
  #sops.environment.SOPS_GPG_EXEC ="qubes-gpg-client";
  #sops.environment.QUBES_GPG_DOMAIN="vault-gpg";
  #sops.gnupg.home="/dev/null";

  sops.gnupg.qubes-split-gpg = { enable = true; domain = "vault-gpg"; };
  sops.secrets.hello = { sopsFile = ./secrets.sops.yaml; };

  # programs
  programs.bat.enable = true;
  programs.direnv.enable = true;

  # files
  home.file = {
    ".npmrc".text = "prefix=${config.home.homeDirectory}/.filesystem";
  };

  home.packages = with pkgs; [
    amazon-ecr-credential-helper
    awscli2
    binutils # for strings
    devbox
    docker-credential-gcr
    duf # du replacement on steroids
    file
    fx # JSON viewer
    gh # GitHub command line client
    gist
    gnugrep
    hexyl # hex viewer with nice colors
    imagemagick # for convert
    inetutils # for telnet
    jq
    mercurial
    nix-index
    nixpkgs-review
    nix-zsh-completions
    nur.repos.kalbasit.swm
    pv # generic progress of data through a pipeline
    scrcpy # mirror Android device via USB
    screen # needed to open up terminal devices
    unzip
  ] ++ (optionals stdenv.isLinux [
    #
    # Linux applications
    #

    _2048-in-terminal
    dnsutils # for dig
    esptool
    gdb
    mbuffer # memory buffer within pipeline
  ]);
}
