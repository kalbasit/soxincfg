{
  pkgs,
  soxincfg,
  ...
}:

{
  imports = [
    soxincfg.nixosModules.profiles.miniserver

    ./hardware-configuration.nix
  ];

  environment.systemPackages = [ pkgs.wakelan ];

  # nixpkgs.config.allowUnfree = true;
  nixpkgs.system = "aarch64-linux";

  system.stateVersion = "23.05";
}
