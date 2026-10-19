# home-manager configuration for user `yl`
{ soxincfg }:
{
  config,
  pkgs,
  home-manager,
  ...
}:

{
  imports = [
    soxincfg.nixosModules.profiles.myself
    soxincfg.nixosModules.profiles.personal
    soxincfg.nixosModules.profiles.workstation.darwin.local
  ];

  # Personal machine: its stories live in maktab.
  soxincfg.services.aerospace.storyManager = "maktab";

  # XXX: This host was created prior to changing my username to wnasreddine.
  soxincfg.settings.users.userName = "yl";

  home.stateVersion = "23.05";

  sops.age.keyFile = "${config.home.homeDirectory}/.local/share/soxincfg/sops/age.key";
}
