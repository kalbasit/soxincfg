# home-manager configuration for user `yl`
{ soxincfg }:

{
  imports = [
    soxincfg.nixosModules.profiles.myself
    soxincfg.nixosModules.profiles.miniserver.qemu-vm-guest
    soxincfg.nixosModules.profiles.server
  ];

  programs.claude-code.enable = true;

  home.stateVersion = "24.11";
}
