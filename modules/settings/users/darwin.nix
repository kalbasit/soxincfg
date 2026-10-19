# Soxin's users (soxin.settings.users) with soxincfg's choices; see nixos.nix.
{
  inputs,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    inputs.soxin.lib.library.darwin.settings-users
    ./aliases.nix
  ];

  soxin.settings.users = {
    enable = lib.mkDefault true;
    userName = lib.mkDefault "wnasreddine";
    shell = pkgs.zsh;
  };
}
