inputs@{ self, lib ? nixpkgs.lib, nixpkgs, ... }:

let
  inherit (lib)
    mapAttrs
    recursiveUpdate
    ;

  # the default channel to follow.
  channelName = "nixpkgs";

  # the hostType of the installation
  hostType = "linux";
in
mapAttrs
  (n: v: recursiveUpdate
  {
    specialArgs = {
      inherit
        hostType
        ;
    };
  }
    v)
{
  hercules =
    let
      system = "x86_64-linux";
    in
    {
      inherit system;

      modules = [
        ./hercules/home.nix
        {
          home = {
            username = "yl";
            homeDirectory = "/home/yl";
            stateVersion = "24.05";
          };
        }
      ];
    };
}
