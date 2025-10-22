{ soxincfg, ... }:

{
  imports = [
    soxincfg.nixosModules.profiles.tailscale.subnet-router

    ../nixos-25.05/nixos.nix
  ];

  fileSystems."/".device = "/dev/disk/by-uuid/4ff2bf09-2972-4b83-b87f-aa6379c9b3f7";

  fileSystems."/boot".device = "/dev/disk/by-uuid/4329-FF5A";

  networking = {
    defaultGateway = {
      address = "192.168.100.1";
      interface = "ens18";
    };

    interfaces.ens18.ipv4.addresses = [
      {
        address = "192.168.100.10";
        prefixLength = 24;
      }
    ];
  };

  # Configure Network Address Translation (NAT) to act as static route for 100.64.0.0/10
  networking.nat = {
    enable = true;
    # Traffic from internalInterfaces will be NAT'd to the externalInterface.
    externalInterface = "tailscale0";
    # Replace 'ens18' with your actual LAN interface name.
    internalInterfaces = [ "ens18" ];
  };
}
