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

  system.stateVersion = "21.11";
}
