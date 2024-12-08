{
  lib,
  soxincfg,
  ...
}:

{
  imports = [
    soxincfg.nixosModules.profiles.myself
    soxincfg.nixosModules.profiles.workstation.qubes.local
  ];
}
