{
  mode,
  lib,
  userName,
}:

let
  inherit (lib) optionalAttrs;
in
optionalAttrs (mode == "NixOS") (import ./nixos.nix userName)
// optionalAttrs (mode == "nix-darwin") (import ./darwin.nix userName)
