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
    [ ]
    ++ optionals (hostType == "linux") [ ./linux.nix ]
    ++ optionals (hostType == "NixOS") [ ./nixos.nix ]
    ++ optionals (hostType == "nix-darwin") [ ./darwin.nix ]
    ++ optionals (hostType == "qubes-os") [ ./qubes.nix ];
}
