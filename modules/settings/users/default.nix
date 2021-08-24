{ mode, config, pkgs, lib, ... }:

with lib;
let
  cfg = config.soxincfg.settings.users;

  defaultGroups = [
    "builders"
    "dialout"
    "fuse"
    "plugdev" # to access ZSA keyboards.
    "users"
    "video"
  ];

  makeUser = userName: { isAdmin, sshKeys, ... }@user:
    {
      group = "mine";
      extraGroups =
        defaultGroups
        ++ cfg.groups
        ++ (optionals isAdmin [ "wheel" ]);

      shell = pkgs.zsh;
      isNormalUser = true;

      openssh.authorizedKeys.keys = sshKeys;
    }
    // (builtins.removeAttrs user [ "isAdmin" "sshKeys" ]);

in
{
  options.soxincfg.settings.users = {
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

      apply = users:
        let
          defaults = {
            hashedPassword = "";
            home = "/home/${userName}";
            isAdmin = false;
            isNixTrustedUser = false;
            sshKeys = [ ];
          };
        in
        # for each user, first use the default, then make sure the name is always
        # set and finally pass the user. Each step will override attributes from
        # the previous one, so it's important the passed-in value is evaluated
        # last.
        mapAttrs
          (name: user:
            defaults
            // { inherit name; }
            // builtins.removeAttrs user [ "homeFunc" ]
            // { home = user.homeFunc { inherit pkgs; }; }
          )
          users;
    };

    groups = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = ''
        The list of groups to add all users to.
      '';
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (optionalAttrs (mode == "NixOS") {
      users = {
        mutableUsers = false;

        groups = {
          builders = { gid = 1999; };
          mine = { gid = 2000; };
        };

        users = mapAttrs makeUser config.soxincfg.settings.users.users;
      };
    })
  ]);
}
