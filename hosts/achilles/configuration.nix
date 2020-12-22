{ config, soxincfg, nixos-hardware, sops-nix, ... }:
{
  imports = [
    soxincfg.nixosModules.profiles.workstation
    soxincfg.nixosModules.profiles.myself

    nixos-hardware.nixosModules.common-cpu-intel
    nixos-hardware.nixosModules.common-pc-laptop
    nixos-hardware.nixosModules.common-pc-ssd

    sops-nix.nixosModules.sops

    ./hardware-configuration.nix
  ];

  # load YL's home-manager configuration
  home-manager.users.yl = import ./home.nix { inherit soxincfg; };

  soxin.hardware.intelBacklight.enable = true;

  # speed up the trackpad
  services.xserver.libinput.enable = true;
  services.xserver.libinput.accelSpeed = "0.5";

  system.stateVersion = "20.09";
}
