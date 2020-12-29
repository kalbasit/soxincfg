{ libvirt, lib, qemu, ... }:

{ vmName, xml, baseDisk ? null }:

{
  after = [ "libvirtd.service" "remote-fs.target" ];
  requires = [ "libvirtd.service" "remote-fs.target" ];
  wantedBy = [ "multi-user.target" ];
  serviceConfig = {
    Type = "oneshot";
    RemainAfterExit = "yes";
  };
  restartIfChanged = false;

  script =
    (lib.optionalString (baseDisk != null) ''
      if ! ${libvirt}/bin/virsh pool-info guest_local_images; then
        ${libvirt}/bin/virsh pool-define-as guest_local_images dir - - - - "/srv/vms/guest_local_images"
        ${libvirt}/bin/virsh pool-build guest_local_images
        ${libvirt}/bin/virsh pool-start guest_local_images
        ${libvirt}/bin/virsh pool-autostart guest_local_images
      fi

      if ! ${libvirt}/bin/virsh vol-key '${vmName}-root.qcow2' --pool guest_local_images &> /dev/null; then
        # ${libvirt}/bin/virsh vol-create-as guest_local_images '${vmName}-root.qcow2' '${builtins.toString baseDisk.diskSize}GiB'
        ${qemu}/bin/qemu-img convert -f qcow2 -O qcow2 -o preallocation=metadata ${baseDisk.image} '/srv/vms/guest_local_images/${vmName}-root.qcow2'
        ${libvirt}/bin/virsh pool-refresh guest_local_images
        ${libvirt}/bin/virsh vol-resize '${vmName}-root.qcow2' '${builtins.toString baseDisk.diskSize}GiB' --pool guest_local_images
      fi
    '') + ''
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
