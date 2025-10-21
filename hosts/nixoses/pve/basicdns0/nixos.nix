{
  soxincfg,
  ...
}:

{
  imports = [
    soxincfg.nixosModules.profiles.tailscale.basicdns

    ../nixos-25.05/nixos.nix
  ];

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
