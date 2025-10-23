{
  soxincfg,
  ...
}:

{
  imports = [
    soxincfg.nixosModules.profiles.tailscale.dns

    ../nixos-25.05/nixos.nix
  ];

  fileSystems."/".device = "/dev/disk/by-uuid/c99797ed-ffc9-4638-a639-99abd9131242";

  fileSystems."/boot".device = "/dev/disk/by-uuid/1FA3-D15C";

  networking = {
    defaultGateway = {
      address = "192.168.20.1";
      interface = "ens18";
    };

    interfaces.ens18.ipv4.addresses = [
      {
        address = "192.168.20.11";
        prefixLength = 24;
      }
    ];

    interfaces.ens19.ipv4 = {
      addresses = [
        {
          address = "192.168.120.11";
          prefixLength = 24;
        }
      ];

      routes = [
        {
          address = "192.168.150.0";
          prefixLength = 24;
          via = "192.168.120.1";
        }

        {
          address = "192.168.151.0";
          prefixLength = 24;
          via = "192.168.120.1";
        }
      ];
    };
  };

  services.keepalived.vrrpInstances.dns_vip = {
    priority = 104;
    unicastPeers = [
      # DNS
      "192.168.20.3"
      "192.168.20.4"
      "192.168.20.5"

      # Basic DNS
      "192.168.20.10"
      # "192.168.20.11" # this machine
    ];
  };
}
