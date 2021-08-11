{ config, soxincfg, ... }:

{
  imports = [
    soxincfg.nixosModules.profiles.myself
    soxincfg.nixosModules.profiles.work.keeptruckin
    soxincfg.nixosModules.profiles.workstation.darwin.local
  ];

  time.timeZone = "America/Los_Angeles";
}
