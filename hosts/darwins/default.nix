inputs@{ ... }:

let
  # the default channel to follow.
  channelName = "nixpkgs";
  output = "darwinConfigurations";
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
      inherit channelName system output;
      modules = [ ./poseidon/configuration.nix ];
    };
}
