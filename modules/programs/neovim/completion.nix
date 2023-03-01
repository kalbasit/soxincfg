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
        cmp-latex-symbols
        cmp-path
        cmp-vsnip
        vim-vsnip

        {
          plugin = nvim-cmp;
          config = ''
            vim.o.completeopt = 'menu,menuone,noselect'

            local cmp = require 'cmp'

            cmp.setup {
              snippet = {
                expand = function(args)
                vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
                end,
              },
              window = {
                completion = cmp.config.window.bordered(),
                documentation = cmp.config.window.bordered(),
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
              },
            }

            cmp.setup.cmdline(':', {
              sources = {
                { name = 'cmdline' }
              }
            })

            require'cmp'.setup.cmdline('/', {
              sources = {
                { name = 'buffer' }
              }
            })
          '';
          type = "lua";
        }
      ];
    };
  };
}
