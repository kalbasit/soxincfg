{
  lib,
  pkgs,
  ...
}:
with lib;
let
  buildWindows10 = vmName: {
    after = [ "libvirtd.service" ];
    requires = [ "libvirtd.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = "yes";
    };
    restartIfChanged = false;

    script =
      let
        xml = pkgs.replaceVars ./win10.xml {
          name = vmName;
          admin_source_dev = "eno1";
          admin_mac_address = "ea:5e:04:11:a1:a3";
          wifi_source_dev = "wlp110s0";
          wifi_mac_address = "f6:ae:e7:2f:7c:93";
        };

      in
      ''
        uuid="$(${getBin pkgs.libvirt}/bin/virsh domuuid '${vmName}' || true)"
          ${getBin pkgs.libvirt}/bin/virsh define <(sed "s/UUID/$uuid/" '${xml}')
          ${getBin pkgs.libvirt}/bin/virsh start '${vmName}'
      '';

    preStop = ''
      ${getBin pkgs.libvirt}/bin/virsh shutdown '${vmName}'
      let "timeout = $(date +%s) + 120"
      while [ "$(${getBin pkgs.libvirt}/bin/virsh list --name | grep --count '^${vmName}$')" -gt 0 ]; do
        if [ "$(date +%s)" -ge "$timeout" ]; then
          # Meh, we warned it...
          ${getBin pkgs.libvirt}/bin/virsh destroy '${vmName}'
        else
          # The machine is still running, let's give it some time to shut down
          sleep 0.5
        fi
      done
    '';
  };
in
{
  systemd.services.libvirtd-guest-win10 = buildWindows10 "win10";
}
