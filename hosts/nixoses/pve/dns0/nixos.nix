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
    priority = 103;
    unicastPeers = [
      # "192.168.20.2" # this machine
      "192.168.20.3"
      "192.168.20.4"
    ];
  };
}
