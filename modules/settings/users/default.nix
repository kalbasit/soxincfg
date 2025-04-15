{
  config,
  lib,
  mode,
  ...
}:

let
  inherit (lib)
    mkOption
    optionals
    types
    ;
in
{
  imports =
    optionals (mode == "NixOS") [ ./nixos.nix ]
    ++ optionals (mode == "nix-darwin") [ ./darwin.nix ];

  options.soxincfg.settings.users = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Enable the management of users and groups.
      '';
    };

    userName = mkOption {
      type = types.str;
      default = "wnasreddine";
      description = ''
        The default username for the main user.
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
}
