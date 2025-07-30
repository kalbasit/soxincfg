{ soxincfg, ... }:

{
  imports = [
    soxincfg.nixosModules.profiles.tailscale.subnet-router

    ../nixos-25.05/nixos.nix
  ];

  # Configure Network Address Translation (NAT) to act as static route for 100.64.0.0/10
  networking.nat = {
    enable = true;
    # Traffic from internalInterfaces will be NAT'd to the externalInterface.
    externalInterface = "tailscale0";
    # Replace 'ens18' with your actual LAN interface name.
    internalInterfaces = [ "ens18" ];
  };
}
