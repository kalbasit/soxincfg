{
  config,
  lib,
  mode,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;

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
                -- completion = cmp.config.window.bordered(),
                -- documentation = cmp.config.window.bordered(),
              },
              mapping = cmp.mapping.preset.insert({
                ['<CR>'] = cmp.mapping.confirm({ select = true }),
              }),
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

            cmp.setup.cmdline('/', {
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
