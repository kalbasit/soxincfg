{ mode, lib, ... }:

let
  inherit (lib) optionals;
in
{
  imports =
    optionals (mode == "NixOS") [ ./nixos.nix ]
    ++ optionals (mode == "nix-darwin") [ ./darwin.nix ]
    ++ optionals (mode == "home-manager") [ ./home.nix ];

  # configure the keyboard
  soxincfg.settings.keyboard.enable = true;

  # configure the theme
  soxin.settings.theme = "gruvbox-dark";
}
