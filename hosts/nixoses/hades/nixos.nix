{ config, soxincfg, nixos-hardware, pkgs, ... }:
let
  sopsFile = ./secrets.sops.yaml;
in
{
  imports = [
    soxincfg.nixosModules.profiles.myself
    soxincfg.nixosModules.profiles.work.keeptruckin
    soxincfg.nixosModules.profiles.work.ulta
    soxincfg.nixosModules.profiles.workstation.nixos.local

    nixos-hardware.nixosModules.common-cpu-intel
    nixos-hardware.nixosModules.common-pc-laptop
    nixos-hardware.nixosModules.common-pc-ssd

    ./hardware-configuration.nix
    ./win10.nix
  ];

  sops.secrets._etc_NetworkManager_system-connections_Nasreddine-VPN_nmconnection = { inherit sopsFile; path = "/etc/NetworkManager/system-connections/Nasreddine-VPN.nmconnection"; };

  # load YL's home-manager configuration
  home-manager.users.yl = import ./home.nix { inherit soxincfg; };

  networking.firewall.allowedTCPPorts = [
    # allow me to use serve_this on my main machine
    6090

    # allow synergy on port 24800
    24800
  ];

  soxin.hardware.intelBacklight.enable = true;

  services.synergy.server = {
    address = "192.168.2.26";
    autoStart = true;
    enable = true;
    screenName = "hades";
    configFile = pkgs.writeText "synergy.conf" ''
      section: screens
          poseidon:
          hades:
      end

      section: links
          hades:
              left = poseidon

          poseidon:
              right = hades
      end

      section: options
          keystroke(control+super+right) = switchInDirection(right)
          keystroke(control+super+left) = switchInDirection(left)
      end
    '';
  };

  system.stateVersion = "20.09";
}
