{
  soxincfg,
  ...
}:

{
  imports = [
    soxincfg.nixosModules.profiles.tailscale.dns

    ../nixos-25.05/nixos.nix
  ];

  services.keepalived.vrrpInstances.dns_vip = {
    priority = 109;
    unicastPeers = [
      # DNS
      "192.168.20.2"
      # "192.168.20.3" # this machine
      "192.168.20.4"

      # Basic DNS
      "192.168.20.10"
      "192.168.20.11"
    ];
  };
}
