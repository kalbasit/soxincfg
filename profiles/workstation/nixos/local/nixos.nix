{ config, ... }:

let
  sopsFile = ./secrets.sops.yaml;
in
{
  environment.homeBinInPath = true;

  # allow the store to be accessed for store paths via SSH
  nix.sshServe = {
    enable = true;
    keys = config.soxincfg.settings.users.users.yl.sshKeys;
  };

  services.gnome.gnome-keyring.enable = true;

  # Enable dconf required by most guis
  programs.dconf.enable = true;

  # Enable TailScale for zero-config VPN service.
  # TODO: I keep losing DNS not sure why
  # services.tailscale.enable = true;

  # Feed the kernel some entropy
  services.haveged.enable = true;

  services.logind = {
    lidSwitch = "hybrid-sleep";
    lidSwitchDocked = "ignore";
    lidSwitchExternalPower = "hybrid-sleep";
    extraConfig = ''
      HandlePowerKey=suspend
    '';
  };

  # Require Password and U2F to login
  security.pam.u2f = {
    enable = true;
    cue = true;
    control = "required";
  };

  # Redshift
  location.latitude = 34.42;
  location.longitude = -122.11;
  services.redshift = {
    brightness.day = "1.0";
    brightness.night = "0.6";
    enable = true;
    temperature.day = 5900;
    temperature.night = 3700;
  };

  # TODO: fix this!
  system.extraSystemBuilderCmds = ''ln -sfn /yl/.surfingkeys.js $out/.surfingkeys.js'';

  # L2TP VPN does not connect without the presence of this file!
  # https://github.com/NixOS/nixpkgs/issues/64965
  system.activationScripts.ipsec-secrets = ''
    touch $out/etc/ipsec.secrets
  '';

  sops.secrets._etc_NetworkManager_system-connections_Nasreddine_nmconnection = { inherit sopsFile; path = "/etc/NetworkManager/system-connections/Nasreddine.nmconnection"; };
  sops.secrets._etc_NetworkManager_system-connections_Nasreddine-ADMIN_nmconnection = { inherit sopsFile; path = "/etc/NetworkManager/system-connections/Nasreddine-ADMIN.nmconnection"; };
  sops.secrets._etc_NetworkManager_system-connections_Ellipsis_Jetpack_4976_nmconnection = { inherit sopsFile; path = "/etc/NetworkManager/system-connections/Ellipsis_Jetpack_4976.nmconnection"; };
  sops.secrets._etc_NetworkManager_system-connections_Wired_connection_nmconnection = { inherit sopsFile; path = "/etc/NetworkManager/system-connections/Wired_connection.nmconnection"; };
}
