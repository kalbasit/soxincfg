# home-manager configuration for user `yl`
{ soxincfg }:

{ pkgs, ... }:
{
  imports = [
    soxincfg.nixosModules.profiles.myself
    soxincfg.nixosModules.profiles.miniserver.qemu-vm-guest
    soxincfg.nixosModules.profiles.server
  ];

  soxincfg.programs.claude-code.enable = true;

  home.packages = [
    pkgs.git-spice
    pkgs.inotify-tools
  ];

  home.stateVersion = "24.11";
}
