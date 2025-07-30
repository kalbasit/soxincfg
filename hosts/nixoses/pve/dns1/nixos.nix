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

  services.keepalived.vrrpInstances.dns1 = {
    interface = "ens18";
    priority = 101;
    virtualRouterId = 20;
    virtualIps = [
      { addr = "192.168.20.20/24"; }
    ];
    trackScripts = lib.attrNames config.services.keepalived.vrrpScripts;
  };
}
