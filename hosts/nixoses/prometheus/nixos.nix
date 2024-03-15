{ config, soxincfg, modulesPath, pkgs, ... }:
let
  sopsFile = ./secrets.sops.yaml;
in
{
  imports = [
    soxincfg.nixosModules.profiles.myself
    soxincfg.nixosModules.profiles.server

    ./containers.nix
    ./hardware-configuration.nix
    ./unifi.nix
    ./k3s.nix
  ];

  # load YL's home-manager configuration
  home-manager.users.yl = import ./home.nix { inherit soxincfg; };

  soxin.hardware.lowbatt.enable = true;

  environment.systemPackages =
    let
      inherit (pkgs)
        nfs-utils
        speedtest-cli
        ;
    in
    [ nfs-utils speedtest-cli ];

  sops.secrets = {
    "networking.wireless.environmentFile" = { inherit sopsFile; };
  };

  # Don't allow systemd to stop the Tailscale service because that wreck havoc
  # on my network and containers.
  systemd.services.tailscaled.restartIfChanged = false;

  # Disable firewall for now
  # TODO: Fix the issue and re-enable the firewall.
  # When the firewall is open, I can't reach the right ports on the ifcsn0
  # interface. It's possible that I need to define that on the interface
  # directly.
  networking.firewall.enable = false;

  # define the networking by hand
  networking.wireless = {
    enable = true;
    environmentFile = config.sops.secrets."networking.wireless.environmentFile".path;
    networks = {
      "Nasreddine-ServerNetwork0" = {
        psk = "@PSK_NASREDDINE_SERVERNETWORK0@";
      };
    };
  };

  system.stateVersion = "23.05";
}
