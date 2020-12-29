{ config, lib, mode, ... }:

with lib;

{
  config = mkMerge [
    (optionalAttrs (mode == "NixOS") (
      let
        yl_home = config.users.users.yl.home;
        owner = config.users.users.yl.name;
        sopsFile = ./secrets.sops.yaml;
      in
      {
        # Add the extra hosts
        networking.extraHosts = ''
          127.0.0.1 docker.keeptruckin.dev docker.keeptruckin.work
        '';

        nix = {
          binaryCaches = [ "http://cache.nixos.org" "https://nix-cache.corp.ktdev.io" ];
          binaryCachePublicKeys = [ "nix-cache.corp.ktdev.io:/xiDfugzrYzUtdUEIvdYBHy48O0169WYHYb/zMdWgLA=" ];
        };

        sops.secrets._etc_NetworkManager_system-connections_KeepTruckin-VPN_nmconnection = { inherit sopsFile; path = "/etc/NetworkManager/system-connections/KeepTruckin-VPN.nmconnection"; };
        sops.secrets._etc_NetworkManager_system-connections_KeepTruckin_nmconnection = { inherit sopsFile; path = "/etc/NetworkManager/system-connections/KeepTruckin.nmconnection"; };
        sops.secrets._ssh_config_include_work_keeptruckin = { inherit owner sopsFile; path = "${yl_home}/.ssh/config_include_work_keeptruckin"; };
      }
    ))

    (mkIf config.soxincfg.programs.ssh.enable (optionalAttrs (mode == "home-manager") {
      programs.ssh.extraConfig = ''
        Include config_include_work_keeptruckin
      '';
    }))
  ];
}
