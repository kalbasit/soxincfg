{
  hostType,
  lib,
  ...
}:

let
  inherit (lib) optionals;
in
{
  imports =
    [ ./home-config.nix ];

  soxincfg.programs = {
    # TODO: I don't want to build these on Linux yet.
    vscode.enable = hostType == "nix-darwin";
    zellij.enable = hostType == "nix-darwin";
    zed.enable = hostType == "nix-darwin";

    maktab.enable = true;
  };
}
