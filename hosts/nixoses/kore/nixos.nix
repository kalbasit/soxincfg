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

  # nixpkgs.config.allowUnfree = true;
  nixpkgs.system = "aarch64-linux";

  services.tailscale.enable = true;

  system.stateVersion = "23.05";
}
