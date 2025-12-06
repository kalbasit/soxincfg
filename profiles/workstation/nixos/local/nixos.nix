{ config, lib, ... }:

let
  sopsFile = ./secrets.sops.yaml;
in
{
  environment.homeBinInPath = true;

  # allow the store to be accessed for store paths via SSH
  nix.sshServe = {
    inherit (config.soxincfg.settings.users.user.openssh.authorizedKeys) keys;

    enable = true;
  };

  services = {
    gnome.gnome-keyring.enable = true;

    # Enable TailScale for zero-config VPN service.
    tailscale.enable = true;

    # Feed the kernel some entropy
    haveged.enable = true;

    logind = {
      settings.Login = {
        HandlePowerKey = "suspend";
        lidSwitch = "ignore";
        lidSwitchDocked = "ignore";
        lidSwitchExternalPower = "ignore";
      };
    };

    redshift = {
      brightness.day = "1.0";
      brightness.night = "1.0";
      enable = true;
      temperature.day = 5900;
      temperature.night = 3700;
    };
  };

  # Enable dconf required by most guis
  programs.dconf.enable = true;

  # Require Password and U2F to login
  security.pam.u2f = {
    control = "required";
    settings = {
      enable = true;
      cue = true;
    };
  };

  # TODO: fix this!
  system.systemBuilderCommands = ''ln -sfn /home/yl/.surfingkeys.js $out/.surfingkeys.js'';

  # work around bug https://github.com/NixOS/nixpkgs/issues/180175
  systemd.services.NetworkManager-wait-online.enable = lib.mkForce false;

  sops.secrets = {
    _etc_NetworkManager_system-connections_Hermes_nmconnection = {
      inherit sopsFile;
      path = "/etc/NetworkManager/system-connections/Hermes.nmconnection";
    };

    _etc_NetworkManager_system-connections_Nasreddine_nmconnection = {
      inherit sopsFile;
      path = "/etc/NetworkManager/system-connections/Nasreddine.nmconnection";
    };

    _etc_NetworkManager_system-connections_Wired_connection_nmconnection = {
      inherit sopsFile;
      path = "/etc/NetworkManager/system-connections/Wired_connection.nmconnection";
    };
  };
}
