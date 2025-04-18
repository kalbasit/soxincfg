inputs@{
  self,
  darwin,
  deploy-rs,
  lib ? nixpkgs.lib,
  nixpkgs,
  ...
}:

let
  inherit (lib) mapAttrs recursiveUpdate;

  # the default channel to follow.
  channelName = "nixpkgs";

  # the operating mode of Soxin
  mode = "nix-darwin";

  # the hostType of the installation
  hostType = "nix-darwin";
in
mapAttrs
  (
    n: v:
    recursiveUpdate {
      inherit mode;

      specialArgs = {
        inherit hostType;
      };
    } v
  )
  {
    ###
    # aarch64-darwin
    ###

    saturn =
      let
        system = "aarch64-darwin";
      in
      {
        inherit channelName system;

        modules = [ ./saturn/darwin.nix ];
      };

    ###
    # x86_64-darwin
    ###

    poseidon =
      let
        system = "x86_64-darwin";
      in
      {
        inherit channelName system;

        modules = [ ./poseidon/darwin.nix ];
      };
  }
