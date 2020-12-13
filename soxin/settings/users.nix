{ mode, config, pkgs, lib, ... }:

with lib;
let
  makeUser = userName: { uid, isAdmin ? false, home ? "/home/${userName}", hashedPassword ? "", sshKeys ? [ ] }: nameValuePair
    userName
    {
      inherit home uid hashedPassword;

      group = "mine";
      extraGroups = [
        "builders"
        "dialout"
        "fuse"
        "users"
        "video"
      ]
      ++ config.soxin.users.groups
      ++ (optionals isAdmin [ "wheel" ]);

      shell = pkgs.zsh;
      isNormalUser = true;

      openssh.authorizedKeys.keys = sshKeys;
    };

in
{
  options.soxin.users = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Enable the management of users and groups.
      '';
    };

    users = mkOption {
      type = types.attrs;
      default = { };
      description = ''
        The list of users to create.
      '';
    };

    groups = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = ''
        The list of groups to add all users to.
      '';
    };
  };

  config = mkIf config.soxin.users.enable (mkMerge [
    (optionalAttrs (mode == "NixOS") {
      users = {
        mutableUsers = false;

        groups = {
          builders = { gid = 1999; };
          mine = { gid = 1000; };
        };

        users = mapAttrs' makeUser config.soxin.users.users;
      };
    })
  ]);
}
