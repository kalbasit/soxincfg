{ config, lib, pkgs, ... }:
with lib;
# TODO: Copy these over to NixOS
# Copied form https://github.com/open-iscsi/open-iscsi/tree/f37d5b653f9f251845db3f29b1a3dcb90ec89731/etc/systemd
{
  systemd.services.iscsi-init = {
    description = "One time configuration for iscsi.service";
    unitConfig = {
      ConditionPathExists = "!/etc/iscsi/initiatorname.iscsi";
    };
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = "no";
      ExecStart = with pkgs; writeShellScript "iscsi-init.sh" ''
        echo "InitiatorName=$(${getBin pkgs.openiscsi}/sbin/iscsi-iname)" > /etc/iscsi/initiatorname.iscsi
      '';
    };
  };

  systemd.services.iscsi = {
    description = "Login and scanning of iSCSI devices";
    documentation = singleton "man:iscsiadm(8) man:iscsid(8)";
    before = singleton "remote-fs.target";
    after = [ "network.target" "network-online.target" "iscsid.service" "iscsi-init.service" ];
    requires = [ "iscsid.socket" "iscsi-init.service" ];
    wantedBy = [ "remote-fs.target" ];

    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${getBin pkgs.openiscsi}/sbin/iscsiadm -m node --loginall=automatic";
      ExecStop = [
        "${getBin pkgs.openiscsi}/sbin/iscsiadm -m node --logoutall=automatic"
        "${getBin pkgs.openiscsi}/sbin/iscsiadm -m node --logoutall=manual"
      ];
      SuccessExitStatus = "21 15";
      RemainAfterExit = "true";
    };
  };

  systemd.services.iscsid = {
    description = "Open-iSCSI";
    documentation = singleton "man:iscsid(8) man:iscsiuio(8) man:iscsiadm(8)";
    after = [ "network.target" "iscsiuio.service" ];
    before = singleton "remote-fs-pre.target";
    wants = singleton "remote-fs-pre.target";
    wantedBy = singleton "multi-user.target";
    unitConfig = {
      DefaultDependencies = "no";
    };

    serviceConfig = {
      Type = "notify";
      NotifyAccess = "main";
      ExecStart = "${getBin pkgs.openiscsi}/sbin/iscsid -f";
      KillMode = "mixed";
      Restart = "on-failure";
    };
  };


  systemd.services.iscsiuio = {
    description = "iSCSI UserSpace I/O driver";
    documentation = singleton "man:iscsiuio(8)";
    conflicts = singleton "shutdown.target";
    requires = singleton "iscsid.service";
    bindsTo = singleton "iscsid.service";
    after = singleton "network.target";
    before = [ "remote-fs-pre.target" "iscsid.service" ];
    wants = singleton "remote-fs-pre.target";
    wantedBy = singleton "multi-user.target";

    unitConfig = {
      DefaultDependencies = "no";
    };

    serviceConfig = {
      Type = "notify";
      NotifyAccess = "main";
      ExecStart = "${getBin pkgs.openiscsi}/sbin/iscsiuio -f";
      KillMode = "mixed";
      Restart = "on-failure";
    };
  };
}
