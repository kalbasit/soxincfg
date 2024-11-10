inputs@{ self, lib ? nixpkgs.lib, nixpkgs, ... }:

let
  inherit (lib)
    mapAttrs
    recursiveUpdate
    ;

  # the default channel to follow.
  channelName = "nixpkgs";

  # the hostType of the installation
  hostType = "qubes-os";
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
  code-template =
    let
      system = "x86_64-linux";
    in
    {
      inherit system;

      modules = [
        ./code-template/home.nix
        {
          home = {
            username = "user";
            homeDirectory = "/home/user";
            stateVersion = "24.05";
          };
        }
      ];
    };
}
