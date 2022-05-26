{ config, lib, mode, pkgs, ... }:

let
  inherit (lib)
    mkEnableOption
    mkIf
    ;

  inherit (pkgs)
    vimPlugins
    ;

  cfg = config.soxincfg.programs.neovim;
in
{
  options.soxincfg.programs.neovim.treesitter = {
    enable = mkEnableOption "programs.neovim.treesitter";
  };

  config = mkIf cfg.treesitter.enable {
    soxin.programs.neovim.plugins = with vimPlugins;[
      (nvim-treesitter.withPlugins (plugins: pkgs.tree-sitter.allGrammars))
      nvim-treesitter-context
    ];
  };
}
