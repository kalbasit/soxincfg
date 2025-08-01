{
  pkgs,
  soxincfg,
  ...
}:

{
  imports = [
    soxincfg.nixosModules.profiles.miniserver.metal

    ./hardware-configuration.nix
  ];

  environment.systemPackages = [ pkgs.wakelan ];

  services.tailscale.enable = true;

  system.stateVersion = "23.05";
}
