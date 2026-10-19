# Soxin's users (soxin.settings.users), read by home-manager modules; see
# nixos.nix.
{ inputs, lib, ... }:

{
  imports = [
    inputs.soxin.lib.library.home.settings-users
    ./aliases.nix
  ];

  soxin.settings.users = {
    enable = lib.mkDefault true;
    userName = lib.mkDefault "wnasreddine";
  };
}
