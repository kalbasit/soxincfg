{
  mode,
  config,
  lib,
  ...
}:

with lib;
let
  cfg = config.soxin.virtualisation.virtualbox;
in
{
  options = {
    soxin.virtualisation.virtualbox = {
      enable = mkEnableOption "Enable virtualbox.";
      addAdminUsersToGroup = recursiveUpdate (mkEnableOption ''
        Whether to add admin users declared in soxincfg.settings.users to the `virtualbox`
        group.
      '') { default = true; };
    };
  };

  config = mkIf (cfg.enable) (mkMerge [
    (optionalAttrs (mode == "NixOS") {
      virtualisation.virtualbox.host.enable = true;
      virtualisation.virtualbox.host.enableExtensionPack = true;

      soxincfg.settings.users.groups = optional cfg.addAdminUsersToGroup "vboxusers";
    })
  ]);
}
