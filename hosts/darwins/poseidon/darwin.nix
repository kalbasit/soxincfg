{
  config,
  lib,
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

  # load home-manager configuration
  # TODO: Use users.user.name once the following commit is used
  # https://github.com/nix-community/home-manager/commit/216690777e47aa0fb1475e4dbe2510554ce0bc4b
  home-manager.users."${config.soxincfg.settings.users.userName}" = import ./home.nix {
    inherit soxincfg;
  };

  system.stateVersion = 5;
}
