inputs@{ darwin, ... }:

let
  # the default channel to follow.
  channelName = "nixpkgs";
  output = "darwinConfigurations";

  # Build host with darwinSystem. `removeAttrs` workaround due to https://github.com/LnL7/nix-darwin/issues/319
  builder = args: darwin.lib.darwinSystem (builtins.removeAttrs args [ "system" ]);
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
