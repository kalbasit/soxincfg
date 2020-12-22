{ config, soxincfg, lib, nixos-hardware, pkgs, ... }:
with lib;
let
  nasIP = "192.168.53.2";

  buildWindows10 = env:
    let
      vmName =
        if env == "prod" then "win10"
        else if env == "staging" then "win10.staging"
        else abort "${env} is not supported";
    in
    {
      after = [ "libvirtd.service" "iscsid.service" "iscsid-nas.service" ];
      requires = [ "libvirtd.service" "iscsid.service" "iscsid-nas.service" ];
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

            source_dev = "ifcns1";
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
  imports = [
    soxincfg.nixosModules.profiles.myself
    soxincfg.nixosModules.profiles.work.keeptruckin
    soxincfg.nixosModules.profiles.remote-workstation

    nixos-hardware.nixosModules.common-cpu-intel
    nixos-hardware.nixosModules.common-pc-ssd

    ./hardware-configuration.nix
  ];

  # load YL's home-manager configuration
  home-manager.users.yl = import ./home.nix { inherit soxincfg; };

  soxin.hardware.intelBacklight.enable = true;

  # Setup the builder account
  users.users = {
    builder = {
      extraGroups = ["builders"];
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCuo827opqwiOj526m5OjuPa0QnrfWeaQC5aJsXt8O3sonep0o2gA/2gez8AlzD9MNwwqXV/bxDbo97Fo1VKf2emQrIOXBGleYKud5jBr3/X6AInmK7wHhPphclygFctmY509ueQpUeBHsCrfZ24XzSfoAoaTT1HkYYsW804iXz2/ka0h4CYErhYI0XpFfaHDyh6hDif5zYNmHj9Z9t4f9oQErv3ZguGo9/PdaQ/TVIHcGVaCXaheAxhRmxWmTgIyFhLfFLL605bJcOFgN6GxprUq2t2Mo+zkP/XBkYEJXRN0SBwEHGEkwnzHoM4Rzug8IitEf2UwWZQS5skJTC9Rrqtz8lbht+s9jmsXTyETQk3siTQxgEWUcU8fzWsNFzrikx18rGAIR4INzlXcHPUVrdf8m1/5aU6OoTPqFY1XcVS7jzPhqwttE5PoaG3DmPuZMwzgK1gwHG3J/n965fo8LwSyX0nd75K/WGCy+D5XvuhAVdvvpv/a3cM1aJFNxd/pO4Tv+bFKzDEMwW8SbWuPDu6UsIzvKHKh31kiJFyMrv+R1W4ESE8PxVlqGrcTM4utEwQeIdLIAhzxmuU0immWS8kbevohCX3E4t6vhbXfiUQVaB3LEeLt+7i7nDcEWZflZfbKB70+TWRpffFKLNYJ5AqwqY9k0aLsbFWzWR7fv4Ow== Zeus Builder"
      ];
      isNormalUser = true;
    };
  };

  # enable iScsi with libvirtd
  nixpkgs.overlays = [
    (self: super: {
      libvirt = super.libvirt.override {
        enableIscsi = true;
      };
    })
  ];

  # start iscsid
  systemd.services.iscsid = {
    wantedBy = [ "multi-user.target" ];
    before = [ "libvirtd.service" ];
    serviceConfig.ExecStart = "${getBin pkgs.openiscsi}/bin/iscsid --foreground";
    restartIfChanged = false;
  };
  systemd.services.iscsid-nas = {
    wantedBy = [ "multi-user.target" ];
    after = [ "iscsid.service" ];
    requires = [ "iscsid.service" ];
    restartIfChanged = false;
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = "yes";
    };
    script =
      let
        prodIQN = "iqn.2018-11.com.nasreddine.apollo:win10";
        stagingIQN = "iqn.2018-11.com.nasreddine.apollo:win10.staging";
      in
      ''
        export PATH="$PATH:${getBin pkgs.openiscsi}/bin"

        if ! [[ -f /etc/iscsi/initiatorname.iscsi ]]; then
          mkdir -p /etc/iscsi
          echo "InitiatorName=$(iscsi-iname)" > /etc/iscsi/initiatorname.iscsi
        fi

        # run iscsi discover, this might fail and that's OK!
        let "timeout = $(date +%s) + 60"
        while ! iscsi_discovery ${nasIP}; do
          if [ "$(date +%s)" -ge "$timeout" ]; then
            echo "unable to run iscsi_discovery, going to skip this step"
            break
          else
            sleep 0.5
          fi
        done

        # discover all the iSCSI defices offered by my NAS
        let "timeout = $(date +%s) + 60"
        while ! iscsiadm --mode discovery --type sendtargets --portal ${nasIP}; do
          if [ "$(date +%s)" -ge "$timeout" ]; then
            echo "iSCSI is still not up, aborting"
            exit 1
          else
            sleep 0.5
          fi
        done

        # Login to the IQN
        if ! iscsiadm -m session | grep -q ' ${prodIQN} '; then
          iscsiadm -m node -T ${prodIQN} -p ${nasIP} -l
        fi
        if ! iscsiadm -m session | grep -q ' ${stagingIQN} '; then
          iscsiadm -m node -T ${stagingIQN} -p ${nasIP} -l
        fi
      '';
  };

  # start windows 10 VM
  systemd.services.libvirtd-guest-win10 = buildWindows10 "prod";
  # systemd.services.libvirtd-guest-win10-staging = buildWindows10 "staging";

  # configure OpenSSH server to listen on the ADMIN interface
  services.openssh.listenAddresses = [{ addr = "192.168.2.3"; port = 22; }];
  systemd.services.sshd = {
    after = [ "network-addresses-ifcadmin.service" ];
    requires = [ "network-addresses-ifcadmin.service" ];
    serviceConfig = {
      RestartSec = "5";
    };
  };

  #
  # Network
  #

  # TODO(high): For some reason, when the firewall is enabled, I can't seem to
  # connect via SSH.
  networking.firewall.enable = mkForce false;

  # disable the networkmanager on Zeus as it is really not needed since the
  # network does never change.
  networking.networkmanager.enable = false;

  networking.vlans = {
    # The ADMIN interface
    ifcadmin = {
      id = 2;
      interface = "enp0s31f6";
    };

    # SN0 interface
    ifcns0 = {
      id = 50;
      interface = "enp2s0f0";
    };

    # SN1 interface
    ifcns1 = {
      id = 51;
      interface = "enp2s0f1";
    };

    # SN2 interface
    ifcns2 = {
      id = 52;
      interface = "enp4s0f0";
    };

    # SN3 interface
    ifcns3 = {
      id = 53;
      interface = "enp4s0f1";
    };
  };

  networking.interfaces = {
    # turn off DHCP on all real interfaces, I use virtual networks.
    enp2s0f0 = { useDHCP = false; };
    enp2s0f1 = { useDHCP = false; };
    enp4s0f0 = { useDHCP = false; };
    enp4s0f1 = { useDHCP = false; };
    enp0s31f6 = { useDHCP = false; };

    # The ADMIN interface
    ifcadmin = {
      useDHCP = true;
    };

    # SN0 address
    ifcns0 = {
      useDHCP = true;
    };

    # SN1 address
    ifcns1 = {
      useDHCP = true;
    };

    # SN2 address
    ifcns2 = {
      useDHCP = true;
    };

    # SN3 address
    ifcns3 = {
      useDHCP = true;
    };
  };

  system.stateVersion = "20.09";
}
