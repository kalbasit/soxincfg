{ config, lib, mode, ... }:

let
  inherit (lib)
    mkEnableOption
    optionals
    recursiveUpdate
    ;

  cfg = config.soxin.virtualisation.docker;
in
{
  imports =
    [ ]
    ++ optionals (mode == "NixOS") [ ./nixos.nix ]
    ++ optionals (mode == "nix-darwin") [ ./nix-darwin.nix ];

  options = {
    soxin.virtualisation.docker = {
      enable = mkEnableOption "Enable docker.";

      addAdminUsersToGroup = recursiveUpdate
        (mkEnableOption ''
          Whether to add admin users declared in soxincfg.settings.users to the `docker`
          group.
        '')
        { default = true; };
    };
  };
}
