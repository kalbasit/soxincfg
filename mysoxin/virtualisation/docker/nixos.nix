{
  lib,
  ...
}:

let
  inherit (lib) mkEnableOption recursiveUpdate;
in
{
  imports = [ ./nixos-config.nix ];

  options = {
    soxin.virtualisation.docker = {
      enable = mkEnableOption "Enable docker.";

      addAdminUsersToGroup = recursiveUpdate (mkEnableOption ''
        Whether to add admin users declared in soxincfg.settings.users to the `docker`
        group.
      '') { default = true; };
    };
  };
}
