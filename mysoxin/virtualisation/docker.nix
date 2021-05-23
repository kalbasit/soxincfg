{ mode, config, lib, ... }:

with lib;
let
  cfg = config.soxin.virtualisation.docker;
in
{
  options = {
    soxin.virtualisation.docker = {
      enable = mkEnableOption "Enable docker.";
      addAdminUsersToGroup = recursiveUpdate
        (mkEnableOption ''
          Whether to add admin users declared in soxin.users to the `docker`
          group.
        '')
        { default = true; };
    };
  };

  config = mkIf (cfg.enable) (mkMerge [
    (optionalAttrs (mode == "NixOS") {
      virtualisation.docker = {
        enable = true;
      };

      soxin.users.groups = optional cfg.addAdminUsersToGroup "docker";
    })
  ]);
}
