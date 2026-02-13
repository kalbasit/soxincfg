{
  config,
  lib,
  soxincfg,
  ...
}:
let
  homePath = config.users.users.wnasreddine.home;
  owner = config.users.users.wnasreddine.name;
  sopsFile = ./secrets.sops.yaml;

  saturn-ssh-key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJdAYxrp52P5LqBC+b3ayWgtcauMv4W1+yqADxAaLH/k Saturn NixOS VM";
in
{
  imports = [
    soxincfg.nixosModules.profiles.myself
    soxincfg.nixosModules.profiles.miniserver.qemu-vm-guest
    soxincfg.nixosModules.profiles.server

    ./hardware-configuration.nix
    ./nix-builder.nix
  ];

  users.users = {
    root.openssh.authorizedKeys.keys = lib.singleton saturn-ssh-key;
    wnasreddine.openssh.authorizedKeys.keys = lib.singleton saturn-ssh-key;
  };

  sops = {
    age.keyFile = "${homePath}/.config/sops/age/keys.txt";

    secrets = {
      _yl_bw_session_session = {
        inherit owner sopsFile;
        mode = "0400";
        path = "${homePath}/.bw_session";
      };
    };
  };

  # load YL's home-manager configuration
  home-manager.users.wnasreddine = import ./home.nix { inherit soxincfg; };

  networking.firewall.allowedTCPPorts = [
    # allow me to use serve_this on my main machine
    8000
  ];

  services.tailscale.enable = true;

  system.stateVersion = "24.11";
}
