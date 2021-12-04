{ config, lib, mode, pkgs, ... }:


let
  inherit (lib)
    mkDefault
    mkEnableOption
    mkIf
    mkMerge
    optionalAttrs
    optionals
    singleton
    ;

  cfg = config.soxincfg.programs.onlykey;
in
{
  imports =
    [ ]
    ++ optionals (optionalAttrs (mode == "NixOS")) [ ./nixos.nix ]
    ++ optionals (optionalAttrs (mode == "home-manager")) [ ./home.nix ];

  options.soxincfg.programs.onlykey = {
    enable = mkEnableOption "programs.onlykey";

    ssh-support = {
      enable = mkEnableOption "Whether to enable SSH support with OnlyKey.";
    };
  };

  config = mkIf cfg.enable { soxincfg.programs.ssh = { enableSSHAgent = mkDefault cfg.ssh-support.enable; }; };
}
