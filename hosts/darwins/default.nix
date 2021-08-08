inputs@{ darwin, ... }:

let
  # the default channel to follow.
  channelName = "nixpkgs";
  output = "darwinConfigurations";
  builder = darwin.lib.darwinSystem;
in
{
  ###
  # x86_64-linux
  ###

  poseidon =
    let
      system = "x86_64-darwin";
    in
    {
      inherit channelName system output builder;
      modules = [ ./poseidon/configuration.nix ];
    };
}
