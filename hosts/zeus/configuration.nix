{ config, soxincfg, lib, nixos-hardware, pkgs, ... }:
with lib;
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

  # Enable iscsid to create disks over on my NAS
  soxincfg.services.iscsid.enable = true;

  # Setup the builder account
  nix.trustedUsers = [ "root" "@wheel" "@builders" ];
  users.users = {
    builder = {
      extraGroups = [ "builders" ];
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

  # configure OpenSSH server to listen on the ADMIN interface
  services.openssh = {
    listenAddresses = [{ addr = "192.168.2.3"; port = 22; }];
    openFirewall = false;
  };
  systemd.services.sshd = { after = [ "network-interfaces.target" ]; serviceConfig.RestartSec = "5"; };

  # Open the SSH/Eternal-Terminal ports
  networking.firewall.interfaces.ifcadmin.allowedTCPPorts = [
    config.services.eternal-terminal.port
  ] ++ (map (c: c.port) config.services.openssh.listenAddresses);

  #
  # Network
  #

  networking.vlans = {
    # The ADMIN interface
    ifcadmin = {
      id = 2;
      interface = "enp0s31f6";
    };

    # SN0 interface
    ifcsn0 = {
      id = 50;
      interface = "ifcbond0";
    };
  };

  networking.bonds = {
    ifcbond0 = {
      interfaces = [ "enp2s0f0" "enp2s0f1" "enp4s0f0" "enp4s0f1" ];
      driverOptions = {
        mode = "802.3ad";
        miimon = "100";
      };
    };
  };

  networking.interfaces = {
    # turn off DHCP on all real interfaces, I use virtual networks.
    # used by the admin interface
    enp0s31f6 = { useDHCP = false; };
    # below are use for the bond interface
    enp2s0f0 = { useDHCP = false; };
    enp2s0f1 = { useDHCP = false; };
    enp4s0f0 = { useDHCP = false; };
    enp4s0f1 = { useDHCP = false; };
    # do not boot the bond interface itself
    ifcbond0 = { useDHCP = false; };

    # The ADMIN interface
    ifcadmin.useDHCP = true;

    # SN0 address
    ifcsn0.useDHCP = true;
  };

  system.stateVersion = "20.09";
}
