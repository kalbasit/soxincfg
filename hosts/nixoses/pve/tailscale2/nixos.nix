{ soxincfg, ... }:

{
  imports = [
    soxincfg.profiles.tailscale.subnet-router

    ../nixos-25.05/nixos.nix
  ];
}
