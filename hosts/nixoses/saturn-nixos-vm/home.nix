# home-manager configuration for user `yl`
{ soxincfg }:

{ pkgs, ... }:
{
  imports = [
    soxincfg.homeModules.profiles.myself
    soxincfg.homeModules.profiles.miniserver.qemu-vm-guest
    soxincfg.homeModules.profiles.server
  ];

  soxincfg.programs.claude-code.enable = true;

  home.packages = [
    pkgs.git-spice
    pkgs.inotify-tools
  ];

  home.stateVersion = "24.11";
}
