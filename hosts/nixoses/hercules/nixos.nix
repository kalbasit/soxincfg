{
  config,
  inputs,
  soxincfg,
  nixos-hardware,
  pkgs,
  lib,
  ...
}:
let
  yl_home = config.users.users.yl.home;
  owner = config.users.users.yl.name;
  sopsFile = ./secrets.sops.yaml;

  inherit (lib) mkForce;
in
{
  imports = [
    soxincfg.nixosModules.profiles.myself
    soxincfg.nixosModules.profiles.personal
    soxincfg.nixosModules.profiles.workstation.nixos.local

    nixos-hardware.nixosModules.common-cpu-intel
    nixos-hardware.nixosModules.common-pc-laptop
    nixos-hardware.nixosModules.common-pc-ssd

    ./hardware-configuration.nix
    ./nvidia.nix
    ./spectrum.nix
  ];

  # TODO: Remove this once I can work out:
  #   - How to ssh into my machine if U2F is required.
  #   - How make 'sudo' ask for password before U2F because Onlykey makes me
  #     wait 3 seconds between U2F presence check and accepting password tap.
  security.pam.u2f.enable = mkForce false;

  sops.secrets = {
    _etc_NetworkManager_system-connections_Nasreddine-VPN_nmconnection = {
      inherit sopsFile;
      path = "/etc/NetworkManager/system-connections/Nasreddine-VPN.nmconnection";
    };
    _yl_bw_session_session = {
      inherit owner sopsFile;
      mode = "0400";
      path = "${yl_home}/.bw_session";
    };
  };

  # load YL's home-manager configuration
  home-manager.users.yl = import ./home.nix { inherit soxincfg; };

  networking.firewall.allowedTCPPorts = [
    # allow me to use serve_this on my main machine
    8000
  ];

  # hmm do I need this?
  soxin.hardware.intelBacklight.enable = true;

  # store u2f for onlykey
  security.pam.u2f.settings.authFile = pkgs.writeText "u2f-mappings" ''
    yl:*,4uA7dsphf1nPxyQ6ncgKrOGi3qwGxHnzq9bweBisoz1Dl5ocpv9r8EnJX/GOWGrNtoXodSlSAhZ25CZOghx0Xw==,es256,+presence
  '';

  # Default is overlay, and the docker image kartoza/postgis fails to boot.
  virtualisation.docker.storageDriver = "zfs";

  # System-wide packages
  environment.systemPackages = [
    # Arch Linux install and support
    pkgs.arch-install-scripts
    pkgs.pacman

    # Debian-based systems
    pkgs.debootstrap
  ];

  system.stateVersion = "23.05";
}
