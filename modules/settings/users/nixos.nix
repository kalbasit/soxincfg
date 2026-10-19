# Soxin's users (soxin.settings.users) with soxincfg's choices. Soxin's module
# is imported one level down, where soxincfg's own configuration of users used
# to sit, so list definitions keep their order.
{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    inputs.soxin.lib.library.nixos.settings-users
    ./aliases.nix
  ];

  config = {
    soxin.settings.users = {
      # Defaults, as soxincfg's module had them: any definition elsewhere
      # wins (setting defaultGroups anywhere replaces this list).
      enable = lib.mkDefault true;
      userName = lib.mkDefault "wnasreddine";
      defaultGroups = lib.mkOptionDefault [
        "builders"
        "dialout"
        "fuse"
        "users"
        "video"
      ];

      primaryGroup = "mine";
      shell = pkgs.zsh;
      userDefaults.hashedPassword = "";
    };

    users = lib.mkIf config.soxin.settings.users.enable {
      mutableUsers = false;

      groups = {
        builders = {
          gid = 1999;
        };
        mine = {
          gid = 2000;
        };
      };
    };
  };
}
