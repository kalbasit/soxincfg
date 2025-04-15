{
  config,
  lib,
  pkgs,
  inputs,
  soxincfg,
  ...
}:

let
  inherit (lib) singleton;
in
{
  imports = [
    soxincfg.nixosModules.profiles.myself
    soxincfg.nixosModules.profiles.personal
    soxincfg.nixosModules.profiles.workstation.darwin.local
  ];

  # XXX: This host was created prior to changing my username to wnasreddine.
  soxincfg.settings.users.userName = "yl";

  # load YL's home-manager configuration
  home-manager.users.yl = import ./home.nix { inherit soxincfg; };

  system.stateVersion = 5;
}
