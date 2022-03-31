{ config, options, pkgs, lib, ... }:

let
  cfg = config.soxincfg.settings.users;

  inherit (lib)
    filter
    mapAttrs
    mkIf
    mkOption
    optionals
    recursiveUpdate
    types
    ;

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
    // (builtins.removeAttrs user [ "isAdmin" "isNixTrustedUser" "sshKeys" ]);

in
{
  options.soxincfg.settings.users.users = mkOption {
    type = types.attrs;
    default = { };
    description = ''
      The list of users to create.
    '';

    # for each user, first use the default, then make sure the name is always
    # set and finally pass the user. Each step will override attributes from
    # the previous one, so it's important the passed-in value is evaluated
    # last.
    apply = users:
      let
        defaults = name: {
          inherit name;
          hashedPassword = "";
          home = "/home/${name}";
          isAdmin = false;
          isNixTrustedUser = false;
          sshKeys = [ ];
        };
      in
      mapAttrs (name: user: recursiveUpdate (defaults name) user) users;
  };

  config = mkIf cfg.enable {
    users = {
      mutableUsers = false;

      groups = {
        builders = { gid = 1999; };
        mine = { gid = 2000; };
      };

      users = mapAttrs makeUser config.soxincfg.settings.users.users;
    };

    nix.trustedUsers =
      let
        user_list = builtins.attrValues config.soxincfg.settings.users.users;
        trustedUsers = filter (user: user.isNixTrustedUser) user_list;
      in
      options.nix.trustedUsers.default ++ map (user: user.name) trustedUsers;
  };
}
