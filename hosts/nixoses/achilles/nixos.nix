{ config, lib, soxincfg, pkgs, ... }:
let
  inherit (lib)
    mkForce
    ;

  sopsFile = ./secrets.sops.yaml;
in
{
  imports = [
    ./hardware-configuration.nix
    ./soxincfg.nix
  ];

  sops.secrets = {
    _etc_NetworkManager_system-connections_Nasreddine-VPN_nmconnection = { inherit sopsFile; path = "/etc/NetworkManager/system-connections/Nasreddine-VPN.nmconnection"; };
  };

  # load YL's home-manager configuration
  home-manager.users.yl = import ./home.nix { inherit soxincfg; };


  # speed up the trackpad
  services.xserver.libinput.enable = true;
  services.xserver.libinput.touchpad.accelSpeed = "0.5";

  # enable fingerprint reader
  services.fprintd.enable = true;
  security.pam.services.login.fprintAuth = true;
  security.pam.services.xscreensaver.fprintAuth = true;
  security.pam.services.sudo.fprintAuth = true;

  # store u2f for onlykey
  security.pam.u2f.authFile = pkgs.writeText "u2f-mappings" ''
    yl:*,EsrzBknqN1TYiIZcvawKOa0ZfLYABVEHwQrhJpEdAnYK4tiACptJmdUjDKuLabJDK9aDlPHXOJ/AqpdxsBH1dw==,es256,+presence
  '';

  system.stateVersion = "21.05";
}
