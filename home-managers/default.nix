inputs@{ ... }:

let
  # inherit (lib)
  #   mapAttrs
  #   recursiveUpdate
  #   ;

  # the default channel to follow.
  # TODO
  # channelName = "nixpkgs";
  # output = "darwinConfigurations";

  # the operating mode of Soxin
  # TODO
  # mode = "nix-darwin";

  # Build host with darwinSystem. `removeAttrs` workaround due to https://github.com/LnL7/nix-darwin/issues/319
  # TODO
  # builder = args: darwin.lib.darwinSystem (builtins.removeAttrs args [ "system" ]);
in
# mapAttrs
  #   (n: v: recursiveUpdate
  #     {
  #       # inherit
  #       #   builder
  #       #   mode
  #       #   output
  #       #   ;
  #     }
  #     v)
{
  penguin = {
    configuration = ./penguin/home.nix;
    homeDirectory = "/home/yl";
    username = "yl";
    system = "x86_64-linux";
  };

  phoenix = {
    configuration = ./phoenix/home.nix;
    homeDirectory = "/home/yl";
    username = "yl";
    system = "x86_64-linux";
  };
}
