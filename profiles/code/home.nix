{ pkgs, ... }:
{
  home.packages = [
    pkgs.flyctl
    pkgs.turso-cli
  ];
}
