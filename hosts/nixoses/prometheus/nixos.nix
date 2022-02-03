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
          displayprogress
          ender3v2tempfix
          octoprint-dashboard
          themeify
          ;
      in
      [
        displayprogress # required for octoprint-dashboard
        ender3v2tempfix # Octoprint warned me that my firmware is broken and this is needed.
        octoprint-dashboard
        themeify
      ];
  };

  # Configure firewall
  networking.firewall = {
    allowedTCPPorts = [
      5000 # For: services.octoprint
    ];
  };

  system.stateVersion = "21.11";
}
