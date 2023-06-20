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
    soxincfg.nixosModules.profiles.miniserver

    ./hardware-configuration.nix
  ];

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

  # nixpkgs.config.allowUnfree = true;
  nixpkgs.system = "aarch64-linux";

  # SSH do not automatically open firewall to control the interfaces.
  services.openssh.openFirewall = false;

  # Allow unifi controller inform on all interfaces
  networking.firewall.allowedTCPPorts = [
    8080 # Unifi Inform port
  ];

  # Allow unifi/ssh on the tailscale interface.
  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [
    22 # ssh
    8443 # unifi
  ];

  # Allow unifi on the server0 interface.
  networking.firewall.interfaces.ifcsn0.allowedTCPPorts = [
    8443 # unifi
  ];

  # Setup the builder account
  nix.settings.trusted-users = [ "root" "@wheel" "@builders" ];
  users.users = {
    builder = {
      extraGroups = [ "builders" ];
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDKBOvTyKSvp4vENrpyFKkZ+OfBBeSXRvR7CWhPBHbGD19Xev+gAF/D1y5zqdaEK6sZuSmWoBfLHatbfWjiz6Yj1uygYtDilyqSaw0tkdsOMihMHtqvkdNugrzPyfyeugdGUPG50tnXbkTyp8QOfxhkqdpwku0NMLMnMDMOKjGzdYlEFvdPANnjiS2FTrDRbTvb4B64t9OgQ0d/tUpuTMRvRSoTLBtlJC5nNFhNKnhDl6lZDMTQyTZSg8iA25W2C2KQVs5IKJ+E+LMS7golD3t1i/S9kN4guo7yoEU5lQ8xGBqDX5Gnqwl1wriKJP1roIS0tqi9yHCSX18oeyotY7Y3mWg5lIwotgOBYJ3X5IIH1L0oG92aK5dyGedoDUUMZ8GcRX98PqW8WUa0lZRaYyPfmpN5tzhJpKaqwtdKhxgMyESx0UUFTmUwPPgTVvd4gb0P989BguwKKggx591FzGOHVpWwoYcR9S4q+3F+bSzxKFAOet8CARPP2f3v3ULG6pjSycrvy16BMnzIr1kUmlzBQfhFhqa0HR6I9VQu1ND2SOZPz11wTE7zdOWMV68A47tvvemCOM9GSHLATbTeDnZNWwVAICUslkYiiLULTev07bh5OuwQfY+IK0IeCZ4Wsvy52nWz1YsVmLcwPqPCpsi0oqyhEFzBpfhMwATWlaSiQw== Kore Builder"
      ];
      isNormalUser = true;
    };
  };

  networking.vlans = {
    ifcsn0 = {
      id = 50;
      interface = "eth0";
    };
  };

  networking.interfaces = {
    ifcsn0 = {
      useDHCP = true;
      macAddress = "b8:27:eb:a8:5e:04";
    };
  };

  system.stateVersion = "23.05";
}
