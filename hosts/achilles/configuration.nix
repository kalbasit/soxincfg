{ config, soxincfg, ... }:
{
  imports = [
    soxincfg.nixosModules.profiles.workstation
    soxincfg.nixosModules.profiles.myself

    ./hardware-configuration.nix
  ];

  # load yl's home-manager configuration
  home-manager.users.yl = import ./home.nix { inherit soxincfg; };

  soxin.hardware.intelBacklight.enable = true;

  # speed up the trackpad
  services.xserver.libinput.enable = true;
  services.xserver.libinput.accelSpeed = "0.5";

  system.stateVersion = "20.09";
}
