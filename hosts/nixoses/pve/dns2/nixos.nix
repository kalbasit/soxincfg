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

  services.keepalived.vrrpInstances.dns2 = {
    interface = "ens18";
    priority = 100;
    virtualRouterId = 20;
    virtualIps = [
      { addr = "192.168.20.20/24"; }
    ];
    trackScripts = lib.attrNames config.services.keepalived.vrrpScripts;
  };
}
