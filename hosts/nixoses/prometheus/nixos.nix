{ config, soxincfg, modulesPath, ... }:
let
  sopsFile = ./secrets.sops.yaml;
in
{
  imports = [
    soxincfg.nixosModules.profiles.server

    ./hardware-configuration.nix
  ];

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

  services.mjpg-streamer.enable = true;

  # Configure firewall
  networking.firewall = {
    allowedTCPPorts = [
      config.services.octoprint.port
      5050 # For: services.mjpg-streamer
    ];
  };

  system.stateVersion = "21.11";
}
