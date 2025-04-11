{ soxincfg }:
{
  config,
  pkgs,
  home-manager,
  lib,
  ...
}:

let
  inherit (lib)
    mkForce
    ;

  homePath = config.home.homeDirectory;
in
{
  imports = [
    soxincfg.nixosModules.profiles.myself
    soxincfg.nixosModules.profiles.personal
    soxincfg.nixosModules.profiles.neovim
    soxincfg.nixosModules.profiles.workstation.darwin.local
  ];

  # turn off i3-like stuff for now
  soxincfg.services = {
    borders.enable = mkForce false;
    sketchybar.enable = mkForce false;
  };

  home.stateVersion = "24.11";

  sops = {
    age.keyFile = "${homePath}/Library/Application Support/sops/age/keys.txt";
  };
}
