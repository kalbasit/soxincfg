{ config, lib, mode, ... }:

let
  inherit (lib)
    mkEnableOption
    optionals
    ;

  cfg = config.soxincfg.settings.nix.distributed-builds;
in
{
  imports =
    [ ]
    ++ optionals (mode == "NixOS") [ ./nixos.nix ]
    ++ optionals (mode == "nix-darwin") [ ./darwin.nix ]
    ++ optionals (mode == "home-manager") [ ./home.nix ];

  options.soxincfg.settings.nix.distributed-builds.enable = mkEnableOption "Configure Nix distributed-builds";
}
