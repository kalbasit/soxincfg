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
  };

  services.keepalived.vrrpInstances.dns_vip = {
    priority = 105;
    unicastPeers = [
      # DNS
      "192.168.20.2"
      "192.168.20.3"
      "192.168.20.4"

      # Basic DNS
      # "192.168.20.10" # this machine
      "192.168.20.11"
    ];
  };
}
