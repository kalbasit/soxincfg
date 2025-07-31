{ soxincfg }:
{
  config,
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

  home.stateVersion = "24.11";

  sops = {
    age.keyFile = "${homePath}/Library/Application Support/sops/age/keys.txt";
  };
}
