{ soxincfg, ... }:

{
  imports = [
    soxincfg.nixosModules.profiles.tailscale.subnet-router

    ../nixos-25.05/nixos.nix
  ];
}
