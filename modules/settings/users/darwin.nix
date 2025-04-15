{
  config,
  pkgs,
  lib,
  ...
}:

with lib;
let
  cfg = config.soxincfg.settings.users;

  # makeUser = userName: { isAdmin, sshKeys, ... }@user:
  makeUser =
    userName: user:
    {
      shell = pkgs.zsh;
    }
    // (builtins.removeAttrs user [
      "isAdmin"
      "isNixTrustedUser"
      "sshKeys"
    ]);

in
{
  options.soxincfg.settings.users = {
    user = mkOption {
      type = types.attrs;
      default = config.users.users."${cfg.userName}";
      readOnly = true;
      description = ''
        The computed attributes of the main user.
      '';
    };

    users = mkOption {
      type = types.attrs;
      default = { };
      description = ''
        The list of users to create.
      '';

      # for each user, first use the default, then make sure the name is always
      # set and finally pass the user. Each step will override attributes from
      # the previous one, so it's important the passed-in value is evaluated
      # last.
      apply =
        users:
        let
          defaults = name: {
            inherit name;
            # hashedPassword = "";
            home = "/Users/${name}";
            # isAdmin = false;
            # isNixTrustedUser = false;
            # sshKeys = [ ];
          };
        in
        mapAttrs (name: user: recursiveUpdate (defaults name) user) users;
    };
  };

  config = mkIf cfg.enable {
    users = {
      # groups = {
      #   builders = { gid = 1999; };
      #   mine = { gid = 2000; };
      # };

      users = mapAttrs makeUser config.soxincfg.settings.users.users;
    };

    # nix.trustedUsers =
    #   let
    #     user_list = builtins.attrValues config.soxincfg.settings.users.users;
    #     trustedUsers = filter (user: user.isNixTrustedUser) user_list;
    #   in
    #   options.nix.trustedUsers.default
    #   ++ map (user: user.name) trustedUsers;
  };
}
