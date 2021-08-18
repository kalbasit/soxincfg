{ config, pkgs, soxincfg, ... }:

{
  imports = [
    soxincfg.nixosModules.profiles.myself
    soxincfg.nixosModules.profiles.work.keeptruckin
    soxincfg.nixosModules.profiles.workstation.darwin.local
  ];

  # load YL's home-manager configuration
  home-manager.users.yl = import ./home.nix { inherit soxincfg; };

  users.users.yl = {
    home = "/Users/yl";
    shell = pkgs.zsh;
  };

  time.timeZone = "America/Los_Angeles";
}
