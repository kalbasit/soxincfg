{
  pkgs,
  soxincfg,
  ...
}:

{
  imports = [
    soxincfg.nixosModules.profiles.miniserver.metal
    soxincfg.nixosModules.profiles.tailscale.subnet-router

    ./hardware-configuration.nix
  ];

  environment.systemPackages = [ pkgs.wakelan ];

  networking.networkmanager.enable = true;

  services.tailscale.enable = true;

  system.stateVersion = "25.11";
}
