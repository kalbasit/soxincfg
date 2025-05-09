{
  mode,
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
    (optionalAttrs (mode == "NixOS") {
      virtualisation.libvirtd = {
        enable = true;
        qemu = {
          ovmf = {
            enable = true;
            packages = [ pkgs.OVMFFull.fd ];
          };
          package = pkgs.qemu_kvm;
          runAsRoot = false;
          swtpm.enable = true;
        };
      };

      # libvirtd now requires polkit
      security.polkit.enable = true;

      soxincfg.settings.users.groups = optional cfg.addAdminUsersToGroup "libvirtd";

      environment.systemPackages = with pkgs; [
        virt-manager
        spice-gtk
      ];
    })
  ]);
}
