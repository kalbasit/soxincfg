{ config, lib, pkgs, soxincfg, ... }:

with lib;
let
  unifi_config_gateway =
    let
      config = { };
    in
    pkgs.writeText "config.gateway.json" (builtins.toJSON config);
in
{
  imports = [
    soxincfg.nixosModules.profiles.server

    ./hardware-configuration.nix
  ];

  # Enable dnsmasq
  networking.firewall.allowedUDPPorts = singleton 53;
  networking.firewall.interfaces.ifcadmin.allowedUDPPorts = singleton 53;
  networking.firewall.interfaces.eth0.allowedUDPPorts = singleton 53;
  soxincfg.services.dnsmasq = { enable = true; blockAds = true; };
  services.dnsmasq = {
    servers = [ "192.168.2.1" "192.168.10.1" "192.168.11.1" ];
    extraConfig =
      let
        apollo_ip = "192.168.50.2";
        apollo_hosts = [
          "apollo.nasreddine.com"
          "gitlab.nasreddine.com"
          # "nix-cache.corp.ktdev.io"
          "plex.nasreddine.com"
          "soxincfg.nix-binary-cache.nasreddine.com"

          # "cache.nixos.org"
          # "risson.cachix.org"
          # "yl.cachix.org"
        ];

        hole_ip = "0.0.0.0";
        hole_hosts = [ ];

        kore_ip = "192.168.2.5";
        kore_hosts = [ "unifi.nasreddine.com" ];

        zeus_ip = "192.168.50.3";
        zeus_hosts = [
          "nextcloud.nasreddine.com"
        ];
      in
      builtins.concatStringsSep "\n"
        ((map (host: "address=/${host}/${apollo_ip}") apollo_hosts)
          ++ (map (host: "address=/${host}/${hole_ip}") hole_hosts)
          ++ (map (host: "address=/${host}/${kore_ip}") kore_hosts)
          ++ (map (host: "address=/${host}/${zeus_ip}") zeus_hosts));
  };

  # enable unifi and open the remote port
  services.unifi = {
    enable = true;
    jrePackage = pkgs.jre8_headless;
    unifiPackage = pkgs.unifiStable;
    # XXX: Leaving this in case I need to update it again.
    # unifiPackage = pkgs.unifiStable.overrideAttrs (oa: rec {
    #   version = "6.0.43";
    #   name = "unifi-controller-${version}";
    #
    #   src = pkgs.fetchurl {
    #     url = "https://dl.ubnt.com/unifi/${version}/unifi_sysvinit_all.deb";
    #     sha256 = "sha256-fsqjA61JAIEeLiADAkOjI2ynmD93kNXDkiRfIBzhN7U=";
    #   };
    # });
  };
  systemd.services.unifi.preStart = ''
    mkdir -p /var/lib/unifi/data/sites/default
    ln -nsf ${unifi_config_gateway} /var/lib/unifi/data/sites/default/config.gateway.json
  '';

  # enable Octoprint for printing on my 3D printer remotely.
  services.octoprint.enable = true;

  # nixpkgs.config.allowUnfree = true;
  nixpkgs.system = "aarch64-linux";

  # configure OpenSSH server to listen on the ADMIN interface
  services.openssh = {
    # do not automatically open firewall to control the interfaces.
    openFirewall = false;
    listenAddresses = [
      { addr = "192.168.2.5"; port = 22; } # ssh-in from within my network only from Admin network
      # TODO: Add support for SSH from Tailscale!
    ];
  };
  systemd.services.sshd = { after = [ "network-interfaces.target" ]; serviceConfig.RestartSec = "5"; };

  # Allow unifi/ssh on the admin interface only.
  networking.firewall.interfaces.ifcadmin.allowedTCPPorts = [
    22 # ssh
    8443 # unifi
  ];

  # Allow Octoprint an all networking interfaces
  networking.firewall.allowedTCPPorts = [
    5000 # octoprint
  ];

  # Forward externalport 443 to unifi internally.
  # We don't need to allow access to port 443 here because it gets re-routed to
  # port 8443 which itself we allow.
  networking.firewall.extraCommands = ''
    ip46tables -w -t nat -I PREROUTING -p tcp --dport 443 -j REDIRECT --to-ports 8443 -i ifcadmin
  '';

  # Setup the builder account
  nix.trustedUsers = [ "root" "@wheel" "@builders" ];
  users.users = {
    builder = {
      extraGroups = [ "builders" ];
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDKBOvTyKSvp4vENrpyFKkZ+OfBBeSXRvR7CWhPBHbGD19Xev+gAF/D1y5zqdaEK6sZuSmWoBfLHatbfWjiz6Yj1uygYtDilyqSaw0tkdsOMihMHtqvkdNugrzPyfyeugdGUPG50tnXbkTyp8QOfxhkqdpwku0NMLMnMDMOKjGzdYlEFvdPANnjiS2FTrDRbTvb4B64t9OgQ0d/tUpuTMRvRSoTLBtlJC5nNFhNKnhDl6lZDMTQyTZSg8iA25W2C2KQVs5IKJ+E+LMS7golD3t1i/S9kN4guo7yoEU5lQ8xGBqDX5Gnqwl1wriKJP1roIS0tqi9yHCSX18oeyotY7Y3mWg5lIwotgOBYJ3X5IIH1L0oG92aK5dyGedoDUUMZ8GcRX98PqW8WUa0lZRaYyPfmpN5tzhJpKaqwtdKhxgMyESx0UUFTmUwPPgTVvd4gb0P989BguwKKggx591FzGOHVpWwoYcR9S4q+3F+bSzxKFAOet8CARPP2f3v3ULG6pjSycrvy16BMnzIr1kUmlzBQfhFhqa0HR6I9VQu1ND2SOZPz11wTE7zdOWMV68A47tvvemCOM9GSHLATbTeDnZNWwVAICUslkYiiLULTev07bh5OuwQfY+IK0IeCZ4Wsvy52nWz1YsVmLcwPqPCpsi0oqyhEFzBpfhMwATWlaSiQw== Kore Builder"
      ];
      isNormalUser = true;
    };
  };

  # enable port forwarding as this host act as my home OpenVPN client
  # forwarding network requests to and from my home devices.
  boot.kernel.sysctl."net.ipv4.ip_forward" = "1";

  networking.vlans = {
    # The ADMIN interface
    ifcadmin = {
      id = 2;
      interface = "eth0";
    };
  };

  networking.interfaces = {
    # The ADMIN interface
    ifcadmin = {
      useDHCP = true;
      macAddress = "b8:27:eb:a8:5e:02";
    };
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.09"; # Did you read the comment?
}
