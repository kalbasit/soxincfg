{ soxincfg, ... }:

{
  imports = [
    soxincfg.profiles.tailscale.dns

    ../nixos-25.05/nixos.nix
  ];
}
