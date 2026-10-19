{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.soxin.virtualisation.libvirtd;
in
{
  options = {
    soxin.virtualisation.libvirtd = {
      enable = mkEnableOption "Enable libvirtd.";
      addAdminUsersToGroup = recursiveUpdate (mkEnableOption ''
        Whether to add admin users declared in soxincfg.settings.users to the
        `libvirtd` group.
      '') { default = true; };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    ({ })
  ]);
}
