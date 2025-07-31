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
    priority = 101;
    unicastPeers = [
      "192.168.20.2"
      # "192.168.20.3" # this machine
      "192.168.20.4"
    ];
  };
}
