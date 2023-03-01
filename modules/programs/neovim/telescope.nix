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
          vim.keymap.set('n', '<leader>ff', '<cmd>Telescope find_files<cr>', { noremap = true })
          vim.keymap.set('n', '<leader>fg', '<cmd>Telescope live_grep<cr>', { noremap = true })
          vim.keymap.set('n', '<leader>fb', '<cmd>Telescope buffers<cr>', { noremap = true })
          vim.keymap.set('n', '<leader>fh', '<cmd>Telescope help_tags<cr>', { noremap = true })
        '';
        type = "lua";
      };
    }

    (optionalAttrs (mode == "home-manager") { programs.neovim.extraPackages = [ ripgrep ]; })
  ]);
}
