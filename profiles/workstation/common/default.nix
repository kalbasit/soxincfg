{
  hostType,
  lib,
  mode,
  ...
}:

let
  inherit (lib) optionals;
in
{
  imports =
    optionals (mode == "NixOS") [ ./nixos.nix ] ++ optionals (mode == "home-manager") [ ./home.nix ];

  soxincfg.programs = {
    # TODO: I don't want to build these on Linux yet.
    vscode.enable = hostType == "nix-darwin";
    zellij.enable = hostType == "nix-darwin";
    zed.enable = hostType == "nix-darwin";
  };
}
