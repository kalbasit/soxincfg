inputs@{ self, darwin, deploy-rs, lib ? nixpkgs.lib, nixpkgs, ... }:

let
  inherit (lib)
    mapAttrs
    recursiveUpdate
    ;

  # the default channel to follow.
  channelName = "nixpkgs";

  # the operating mode of Soxin
  mode = "nix-darwin";
in
mapAttrs
  (n: v: recursiveUpdate
    {
      inherit
        mode
        ;
    }
    v)
{
  ###
  # x86_64-darwin
  ###

  poseidon =
    let
      system = "x86_64-darwin";
    in
    {
      inherit
        channelName
        system
        ;

      modules = [ ./poseidon/configuration.nix ];
    };

  ###
  # aarch64-darwin
  ###

  saturn =
    let
      system = "aarch64-darwin";
    in
    {
      inherit
        system
        ;

      channelName = "nixpkgs-unstable";
      modules = [ ./saturn/configuration.nix ];
    };
}
