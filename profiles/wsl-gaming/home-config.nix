{ pkgs, ... }:

{
  # programs
  programs.bat.enable = true;
  programs.direnv.enable = true;

  home.packages = [
    pkgs.file
    pkgs.gnugrep
    pkgs.htop
    pkgs.jq
    pkgs.nil # Nix language server
    pkgs.tree
    pkgs.unzip
    pkgs.wget
  ];
}
