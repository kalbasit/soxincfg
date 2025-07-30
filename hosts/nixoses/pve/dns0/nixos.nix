{
  config,
  lib,
  soxincfg,
  ...
}:

{
  imports = [
    soxincfg.nixosModules.profiles.tailscale.dns

    ../nixos-25.05/nixos.nix
  ];

  services.keepalived.vrrpInstances.dns0 = {
    interface = "ens18";
    priority = 103;
    unicastPeers = [
      # "192.168.20.2" # this machine
      "192.168.20.3"
      "192.168.20.4"
    ];
    virtualRouterId = 20;
    virtualIps = [
      { addr = "192.168.20.20/24"; }
    ];
    trackScripts = lib.attrNames config.services.keepalived.vrrpScripts;
  };
}
