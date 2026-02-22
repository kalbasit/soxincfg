# home-manager configuration for user `yl`
{ soxincfg }:

{ pkgs, ... }:
{
  imports = [
    soxincfg.nixosModules.profiles.myself
    soxincfg.nixosModules.profiles.miniserver.qemu-vm-guest
    soxincfg.nixosModules.profiles.server
  ];

  home.packages = [
    pkgs.graphite-cli
  ];

  programs.claude-code.enable = true;

  home.stateVersion = "24.11";
}
