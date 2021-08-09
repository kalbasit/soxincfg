inputs@{ self, darwin, deploy-rs, lib ? nixpkgs.lib, nixpkgs, ... }:

let
  inherit (lib)
    mapAttrs
    recursiveUpdate
    ;

  # the default channel to follow.
  channelName = "nixpkgs";
  output = "darwinConfigurations";

  # the operating mode of Soxin
  mode = "nix-darwin";

  # Build host with darwinSystem. `removeAttrs` workaround due to https://github.com/LnL7/nix-darwin/issues/319
  builder = args: darwin.lib.darwinSystem (builtins.removeAttrs args [ "system" ]);
in
mapAttrs
  (n: v: recursiveUpdate
    {
      inherit
        builder
        mode
        output
        ;
    }
    v)
{
  ###
  # x86_64-linux
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
}
