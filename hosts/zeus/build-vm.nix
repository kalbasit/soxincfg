{ libvirt, lib, ... }:

{ vmName, xml }:

{
  after = [ "libvirtd.service" "remote-fs.target" ];
  requires = [ "libvirtd.service" "remote-fs.target" ];
  wantedBy = [ "multi-user.target" ];
  serviceConfig = {
    Type = "oneshot";
    RemainAfterExit = "yes";
  };
  restartIfChanged = false;

  script = ''
    uuid="$(${lib.getBin libvirt}/bin/virsh domuuid '${vmName}' || true)"
      ${lib.getBin libvirt}/bin/virsh define <(sed "s/UUID/$uuid/" '${xml}')
      ${lib.getBin libvirt}/bin/virsh start '${vmName}'
  '';

  preStop = ''
    ${lib.getBin libvirt}/bin/virsh shutdown '${vmName}'
    let "timeout = $(date +%s) + 120"
    while [ "$(${lib.getBin libvirt}/bin/virsh list --name | grep --count '^${vmName}$')" -gt 0 ]; do
      if [ "$(date +%s)" -ge "$timeout" ]; then
        # Meh, we warned it...
        ${lib.getBin libvirt}/bin/virsh destroy '${vmName}'
      else
        # The machine is still running, let's give it some time to shut down
        sleep 0.5
      fi
    done
  '';
}
