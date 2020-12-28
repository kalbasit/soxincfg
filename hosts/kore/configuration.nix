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

  soxincfg.services.dnsmasq = {
    enable = true;
    blockAds = true;
  };

  services.dnsmasq = {
    servers = [ "192.168.2.1" "192.168.10.1" "192.168.11.1" ];
    extraConfig =
      let
        apollo_ip = "192.168.50.2";
        apollo_hosts = [
          "apollo.nasreddine.com"
          "nix-cache.corp.ktdev.io"
          "plex.nasreddine.com"
          "soxincfg.nix-binary-cache.nasreddine.com"
          "unifi.nasreddine.com"

          # "cache.nixos.org"
          # "risson.cachix.org"
          # "yl.cachix.org"
        ];

        zeus_ip = "192.168.50.3";
        zeus_hosts = [ ];

        hole_ip = "0.0.0.0";
        hole_hosts = [ "roblox.com" ];
      in
      builtins.concatStringsSep "\n"
        ((map (host: "address=/${host}/${apollo_ip}") apollo_hosts)
          ++ (map (host: "address=/${host}/${zeus_ip}") zeus_hosts)
          ++ (map (host: "address=/${host}/${hole_ip}") hole_hosts));
  };

  # enable unifi and open the remote port
  networking.firewall.allowedTCPPorts = [ 8443 ];
  services.unifi = {
    enable = true;
    jrePackage = pkgs.jre8_headless;
    unifiPackage = pkgs.unifiStable;
  };
  systemd.services.unifi.preStart = ''
    mkdir -p ${config.services.unifi.dataDir}/sites/default
    ln -nsf ${unifi_config_gateway} ${config.services.unifi.dataDir}/sites/default/config.gateway.json
  '';

  # nixpkgs.config.allowUnfree = true;
  nixpkgs.system = "aarch64-linux";

  # configure OpenSSH server to listen on the ADMIN interface
  networking.firewall.enable = mkForce false; # TODO: Why do I have to disable firewall for the ifcadmin interface to work with port 22?
  services.openssh.listenAddresses = [{ addr = "192.168.2.6"; port = 22; }];
  systemd.services.sshd = {
    after = [ "network-addresses-ifcadmin.service" ];
    requires = [ "network-addresses-ifcadmin.service" ];
    serviceConfig = {
      RestartSec = "5";
    };
  };

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

    # The GUEST0 interface
    ifcguest0 = {
      id = 11;
      interface = "eth0";
    };
  };

  networking.interfaces = {
    # The ADMIN interface
    ifcadmin = {
      useDHCP = true;
    };

    # The GUEST0 interface
    ifcguest0 = {
      useDHCP = true;
    };
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.09"; # Did you read the comment?
}
