{ config, lib, mode, pkgs, ... }:

let
  inherit (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.soxincfg.programs.neovim;
in
{
  imports = [
    ./completion.nix
    ./lsp.nix
    ./plugins.nix
    ./telescope.nix
    ./treesitter.nix
  ];

  options.soxincfg.programs.neovim = {
    enable = mkEnableOption "programs.neovim";
  };

  config = mkIf cfg.enable {
    soxin.programs.neovim = {
      inherit (cfg) enable;

      extraConfig = pkgs.callPackage ./customrc.nix { };
      mapleader = ",";
    };
  };
}
