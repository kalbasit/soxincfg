{ config, lib, mode, pkgs, ... }:

let
  inherit (lib)
    mkEnableOption
    mkIf
    mkMerge
    optionalAttrs
    singleton
    ;

  inherit (pkgs)
    vimPlugins
    ripgrep
    ;

  cfg = config.soxincfg.programs.neovim;
in
{
  options.soxincfg.programs.neovim.telescope = {
    enable = mkEnableOption "programs.neovim.telescope";
  };

  config = mkIf cfg.telescope.enable (mkMerge [
    {
      soxin.programs.neovim.plugins = singleton {
        plugin = vimPlugins.telescope-nvim;
        config = ''
          nnoremap <leader>ff <cmd>Telescope find_files<cr>
          nnoremap <leader>fg <cmd>Telescope live_grep<cr>
          nnoremap <leader>fb <cmd>Telescope buffers<cr>
          nnoremap <leader>fh <cmd>Telescope help_tags<cr>
        '';
      };
    }

    (optionalAttrs (mode == "home-manager") { programs.neovim.extraPackages = [ ripgrep ]; })
  ]);
}
