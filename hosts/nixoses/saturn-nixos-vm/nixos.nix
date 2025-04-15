{
  config,
  soxincfg,
  lib,
  ...
}:
let
  homePath = config.users.users.wnasreddine.home;
  owner = config.users.users.wnasreddine.name;
  sopsFile = ./secrets.sops.yaml;

  inherit (lib) mkForce;
in
{
  imports = [
    soxincfg.nixosModules.profiles.myself
    soxincfg.nixosModules.profiles.personal
    soxincfg.nixosModules.profiles.workstation.nixos.vm-guest

    ./hardware-configuration.nix
  ];

  # TODO: Remove this once I can work out:
  #   - How to ssh into my machine if U2F is required.
  #   - How make 'sudo' ask for password before U2F because Onlykey makes me
  #     wait 3 seconds between U2F presence check and accepting password tap.
  security.pam.u2f.enable = mkForce false;

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

  system.stateVersion = "24.11";
}
