{ mode, lib }:

let
  inherit (lib) optionalAttrs;
in
optionalAttrs (mode == "NixOS") (import ./nixos.nix)
// optionalAttrs (mode == "nix-darwin") (import ./darwin.nix)
