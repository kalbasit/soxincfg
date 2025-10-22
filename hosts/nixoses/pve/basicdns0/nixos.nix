{
  soxincfg,
  ...
}:

{
  imports = [
    soxincfg.nixosModules.profiles.tailscale.basicdns

    ../nixos-25.05/nixos.nix
  ];

  fileSystems."/".device = "/dev/disk/by-uuid/90f8e0aa-fec8-4f77-9c2e-f8500a8df389";

  fileSystems."/boot".device = "/dev/disk/by-uuid/51C0-2740";

  networking = {
    defaultGateway = {
      address = "192.168.20.1";
      interface = "ens18";
    };

    interfaces.ens18.ipv4.addresses = [
      {
        address = "192.168.20.10";
        prefixLength = 24;
      }
    ];

    interfaces.ens19.ipv4 = {
      addresses = [
        {
          address = "192.168.120.10";
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
    priority = 105;
    unicastPeers = [
      # DNS
      "192.168.20.3"
      "192.168.20.4"
      "192.168.20.5"

      # Basic DNS
      # "192.168.20.10" # this machine
      "192.168.20.11"
    ];
  };
}
