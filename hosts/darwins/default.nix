inputs@{ ... }:

let
  # the default channel to follow.
  channelName = "nixpkgs";
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
      inherit channelName system;
      modules = [ ./poseidon/configuration.nix ];
    };
}
