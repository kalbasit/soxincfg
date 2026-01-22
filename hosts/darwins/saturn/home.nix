{ soxincfg }:
{
  config,
  lib,
  ...
}:

let
  homePath = config.home.homeDirectory;
in
{
  imports = [
    soxincfg.nixosModules.profiles.myself
    soxincfg.nixosModules.profiles.personal
    soxincfg.nixosModules.profiles.neovim.full
    soxincfg.nixosModules.profiles.workstation.darwin.local
  ];

  soxincfg = {
    # TODO: Move to the darwin workstation profile
    services = {
      borders.enable = lib.mkForce false;
      skhd.enable = lib.mkForce false;
      yabai.enable = lib.mkForce false;
    };
  };

  home.stateVersion = "24.11";

  sops = {
    age.keyFile = "${homePath}/Library/Application Support/sops/age/keys.txt";
  };
}
