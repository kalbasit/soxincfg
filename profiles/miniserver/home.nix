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
  home.packages = with pkgs; [
    binutils # for strings
    dnsutils # for dig
    screen
    duf # du replacement on steroids
    ncdu
    file
    gnupg
    jq
    killall
    nix-zsh-completions
    unzip
  ];
}
