{ config, soxincfg, modulesPath, pkgs, ... }:
let
  sopsFile = ./secrets.sops.yaml;
in
{
  imports = [
    soxincfg.nixosModules.profiles.myself
    soxincfg.nixosModules.profiles.server

    ./hardware-configuration.nix
    ./containers.nix
  ];

  # load YL's home-manager configuration
  home-manager.users.yl = import ./home.nix { inherit soxincfg; };

  soxin.hardware.lowbatt.enable = true;

  environment.systemPackages = [ pkgs.speedtest-cli ];

  sops.secrets = {
    "networking.wireless.environmentFile" = { inherit sopsFile; };
  };

  # Don't allow systemd to stop the Tailscale service because that wreck havoc
  # on my network and containers.
  systemd.services.tailscaled.restartIfChanged = false;

  # define the networking by hand
  networking.wireless = {
    enable = true;
    environmentFile = "/run/secrets/networking.wireless.environmentFile";
    networks = {
      "Nasreddine" = {
        psk = "@PSK_NASREDDINE@";
      };
    };
  };

  networking.vlans = {
    ifcsn0 = {
      id = 50;
      interface = "enp0s31f6";
    };
  };

  networking.interfaces = {
    ifcsn0 = {
      useDHCP = true;
      macAddress = "e8:6a:64:cf:ff:8a";
    };
  };

  system.stateVersion = "23.05";
}
