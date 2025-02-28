{ config, soxincfg, ... }:

{
  imports = [
    soxincfg.nixosModules.profiles.server

    ./hardware-configuration.nix
  ];

  # Don't allow systemd to stop the Tailscale service because that wreck havoc
  # on my network and containers.
  systemd.services.tailscaled.restartIfChanged = false;

  services.k3s.extraFlags = builtins.concatStringsSep " " [
    "--flannel-iface=snbond0" # Use the snbond0 interface
    "--node-label nasreddine.com/has-octoprint-device=yes"
    "--node-label nasreddine.com/has-network-bond=yes"
  ];
  soxincfg.services.k3s = {
    enable = true;
    role = "server";
    serverAddr = "https://192.168.50.16:6443";
  };

  networking.bonds.snbond0 = {
    interfaces = [
      "enp2s0f0"
      "enp2s0f1"
      "enp5s0f0"
      "enp5s0f1"
    ];
    driverOptions = {
      miimon = "100";
      mode = "802.3ad";
    };
  };

  # when firewall is enabled it breaks my k3s setup.
  # TODO: Fix firewall, remove the next line and uncomment the rest.
  networking.firewall.enable = false;
  # networking.firewall.interfaces."snbond0" = {
  #   allowedTCPPorts = config.networking.firewall.allowedTCPPorts;
  #   allowedTCPPortRanges = config.networking.firewall.allowedTCPPortRanges;
  #
  #   allowedUDPPorts = config.networking.firewall.allowedUDPPorts;
  #   allowedUDPPortRanges = config.networking.firewall.allowedUDPPortRanges;
  # };

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.05"; # Did you read the comment?
}
