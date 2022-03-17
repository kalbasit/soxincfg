{ config, soxincfg, modulesPath, pkgs, ... }:
let
  sopsFile = ./secrets.sops.yaml;
in
{
  imports = [
    soxincfg.nixosModules.profiles.myself
    soxincfg.nixosModules.profiles.server

    ./hardware-configuration.nix

    ./arion.nix
  ];

  # load YL's home-manager configuration
  home-manager.users.yl = import ./home.nix { inherit soxincfg; };

  soxin.hardware.lowbatt.enable = true;

  sops.secrets = {
    "networking.wireless.environmentFile" = { inherit sopsFile; };
  };

  # define the networking by hand
  networking.wireless = {
    enable = true;
    environmentFile = "/run/secrets/networking.wireless.environmentFile";
    networks = {
      "Nasreddine-Office" = {
        psk = "@PSK_NASREDDINE_OFFICE@";
      };
    };
  };

  # enable Octoprint for printing on my 3D printer remotely.
  services.octoprint = {
    enable = true;
    plugins = plugins:
      let
        inherit (plugins)
          displaylayerprogress
          ender3v2tempfix
          octolapse
          octoprint-dashboard
          printtimegenius
          themeify
          titlestatus
          bedlevelvisualizer
          ;
      in
      [
        # Octoprint warned me that my firmware is broken and this is needed.
        ender3v2tempfix

        # Take Timelapse of prints
        octolapse

        # Show the print status in the title of the window
        titlestatus

        # Show most relevant information in a dashboard.
        displaylayerprogress # required for octoprint-dashboard
        octoprint-dashboard

        # Add theme support, give me dark mode.
        themeify

        # Better print time estimation.
        printtimegenius

        # Show a visual representation of bed leveling
        bedlevelvisualizer
      ];
  };

  environment.systemPackages = with pkgs; [ minikube kubectl kubetail k9s kubectx ];

  services.mjpg-streamer.enable = true;

  # Configure firewall
  networking.firewall = {
    allowedUDPPorts = [
      #
      # For the Docker containers (see arion-compose.nix)
      #

      # Unifi
      # 10001 # Required for AP discovery
      # 1900 # Required for `Make controller discoverable on L2 network` option
      # 3478 # Unifi STUN port
      # 5514 # Remote syslog port
    ];

    allowedTCPPorts = [
      config.services.octoprint.port
      5050 # For: services.mjpg-streamer
      8123 # For: virtualisation.oci-containers.containers.homeassistant

      #
      # For the Docker containers (see arion-compose.nix)
      #

      # Unifi
      # 8080 # Required for device communication
      # 8443 # Unifi web admin port
      # # 8843 # for guest portal, HTTPS
      # # 8880 # for guest portal, HTTP
      # 6789 # For mobile throughput test
    ];
  };

  system.stateVersion = "21.11";
}
