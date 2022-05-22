{ config, lib, mode, pkgs, ... }:

let
  inherit (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.soxincfg.programs.neovim;
in
{
  options.soxincfg.programs.neovim.completion = {
    enable = mkEnableOption "programs.neovim.completion.enable";
  };

  config = mkIf cfg.completion.enable {
    soxin.programs.neovim = {
      plugins = with pkgs.vimPlugins; [
        cmp-buffer
        cmp-cmdline
        cmp-path

        # TODO: The configuration is actually for nvim-cmp BUT the current plugin
        # configuration simply does not support both regular config and lua config.
        {
          plugin = cmp-latex-symbols;
          config = ''
            set completeopt=menu,menuone,noselect
          '';
        }

        {
          plugin = nvim-cmp;
          config = ''
            local cmp = require 'cmp'

            cmp.setup {
              snippet = {
                expand = function(args)
                vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
                end,
              },
              mapping = {
                ['<C-b>'] = cmp.mapping.scroll_docs(-4),
                ['<C-f>'] = cmp.mapping.scroll_docs(4),
                ['<C-Space>'] = cmp.mapping.complete(),
                ['<C-e>'] = cmp.mapping.abort(),
                ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
              },
              sources = {
                { name = 'vsnip' },
                { name = 'nvim_lsp' },
                { name = 'path' },
                { name = 'buffer' },
                  { name = 'latex_symbols' },
              },
              experimental = { native_menu = true, },
            }
          '';
          type = "lua";
        }

      ];
    };
  };
}
