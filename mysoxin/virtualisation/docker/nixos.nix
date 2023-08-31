{ config, lib, ... }:

let
  inherit (lib)
    mkIf
    optional
    ;

  cfg = config.soxin.virtualisation.docker;
in
{
  config = mkIf cfg.enable {
    virtualisation.docker.enable = true;

    soxincfg.settings.users.groups = optional cfg.addAdminUsersToGroup "docker";
  };
}
