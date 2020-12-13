{ mode, config, lib, ... }:

with lib;
let
  cfg = config.soxin.virtualisation.libvirtd;
in
{
  options = {
    soxin.virtualisation.libvirtd = {
      enable = mkEnableOption "Enable libvirtd.";
      addAdminUsersToGroup = recursiveUpdate
        (mkEnableOption ''
          Whether to add admin users declared in soxin.users to the
          `libvirtd` group.
        '')
        { default = true; };
    };
  };

  config = mkIf (cfg.enable) (mkMerge [
    (optionalAttrs (mode == "NixOS") {
      virtualisation.libvirtd = {
        enable = true;
        qemuRunAsRoot = false;
      };

      soxin.users.groups = optional cfg.addAdminUsersToGroup "libvirtd";
    })
  ]);
}
