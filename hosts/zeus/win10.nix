{ config, lib, pkgs, ... }:
with lib;
let
  nasIP = "192.168.50.2";

  buildWindows10 = env:
    let
      vmName =
        if env == "prod" then "win10"
        else if env == "staging" then "win10.staging"
        else abort "${env} is not supported";
    in
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
        let
          xml = pkgs.substituteAll {
            src = ./win10.xml;

            name = vmName;

            mac_address =
              if env == "prod" then "52:54:00:54:35:95"
              else if env == "staging" then "02:68:b3:29:da:98"
              else abort "${env} is not supported";

            dev_path =
              if env == "prod" then "/dev/disk/by-path/ip-${nasIP}:3260-iscsi-iqn.2018-11.com.nasreddine.apollo:win10-lun-1"
              else if env == "staging" then "/dev/disk/by-path/ip-${nasIP}:3260-iscsi-iqn.2018-11.com.nasreddine.apollo:win10.staging-lun-1"
              else abort "${env} is not supported";

            source_dev = "ifcsn0";
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
  systemd.services.libvirtd-guest-win10 = buildWindows10 "prod";
  # systemd.services.libvirtd-guest-win10-staging = buildWindows10 "staging";
}
