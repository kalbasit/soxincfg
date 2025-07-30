{
  pkgs,
  ...
}:

{
  home.packages = [
    pkgs.binutils # for strings
    pkgs.dnsutils # for dig
    pkgs.screen
    pkgs.duf # du replacement on steroids
    pkgs.ncdu
    pkgs.file
    pkgs.gnupg
    pkgs.jq
    pkgs.killall
    pkgs.nix-zsh-completions
    pkgs.unzip
  ];
}
