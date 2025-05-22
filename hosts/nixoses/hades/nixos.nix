{
  config,
  soxincfg,
  nixos-hardware,
  pkgs,
  lib,
  ...
}:
let
  homePath = config.soxincfg.settings.users.user.home;
  owner = config.soxincfg.settings.users.user.name;
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
    ./win10.nix
  ];

  # XXX: This host was created prior to changing my username to wnasreddine.
  soxincfg.settings.users.userName = "yl";

  services.foldingathome = {
    daemonNiceLevel = 19;
    enable = true;
    user = "Wael_Nasreddine";
  };

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
      path = "${homePath}/.bw_session";
    };
  };

  # load home-manager configuration
  # TODO: Use users.user.name once the following commit is used
  # https://github.com/nix-community/home-manager/commit/216690777e47aa0fb1475e4dbe2510554ce0bc4b
  home-manager.users."${config.soxincfg.settings.users.userName}" = import ./home.nix {
    inherit soxincfg;
  };

  networking.firewall.allowedTCPPorts = [
    # allow me to use serve_this on my main machine
    8000

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

  # store u2f for onlykey
  security.pam.u2f.authFile = pkgs.writeText "u2f-mappings" ''
    yl:*,4uA7dsphf1nPxyQ6ncgKrOGi3qwGxHnzq9bweBisoz1Dl5ocpv9r8EnJX/GOWGrNtoXodSlSAhZ25CZOghx0Xw==,es256,+presence
  '';

  system.stateVersion = "23.05";
}
