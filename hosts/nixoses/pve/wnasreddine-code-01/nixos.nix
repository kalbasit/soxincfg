{
  config,
  lib,
  soxincfg,
  ...
}:

let
  homePath = config.users.users.wnasreddine.home;
  owner = config.users.users.wnasreddine.name;
in
{
  imports = [
    soxincfg.nixosModules.profiles.code

    ../nixos-25.05/nixos.nix
  ];

  fileSystems."/".device = "/dev/disk/by-uuid/90f8e0aa-fec8-4f77-9c2e-f8500a8df389";

  fileSystems."/boot".device = "/dev/disk/by-uuid/51C0-2740";

  sops = {
    age.keyFile = "${homePath}/.config/sops/age/keys.txt";
  };

  # TODO: switch this to its own vlan
  networking.useDHCP = lib.mkForce true;
  # networking = {
  #   defaultGateway = {
  #     address = "192.168.10.1";
  #     interface = "ens18";
  #   };
  #
  #   interfaces.ens18.ipv4.addresses = [
  #     {
  #       address = "192.168.10.253";
  #       prefixLength = 24;
  #     }
  #   ];
  #
  #   interfaces.ens19.ipv4 = {
  #     addresses = [
  #       {
  #         address = "192.168.120.10";
  #         prefixLength = 24;
  #       }
  #     ];
  #
  #     routes = [
  #       {
  #         address = "192.168.150.0";
  #         prefixLength = 24;
  #         via = "192.168.120.1";
  #       }
  #
  #       {
  #         address = "192.168.151.0";
  #         prefixLength = 24;
  #         via = "192.168.120.1";
  #       }
  #     ];
  #   };
  # };
}
