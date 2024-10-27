{ lib, mode, ... }:

let
  inherit (lib)
    mkEnableOption
    optionals
    ;
in
{
  imports =
    [ ]
    ++ optionals (mode == "NixOS") [ ./nixos.nix ]
    ++ optionals (mode == "home-manager") [ ./home-manager.nix ]
    ++ optionals (mode == "nix-darwin") [ ./darwin.nix ];

  options.soxincfg.services.obsidian-vaults-backup.enable = mkEnableOption "Automatically backup Obsidian Vaults";
}

