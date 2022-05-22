{ config, lib, mode, pkgs, ... }:

with lib;
let
  cfg = config.soxincfg.programs.neovim;

  keyboardLayout = config.soxin.settings.keyboard.defaultLayout.console.keyMap;
in
{
  options.soxincfg.programs.neovim = {
    enable = mkEnableOption "programs.neovim";
  };

  config = mkIf cfg.enable {
    soxin.programs.neovim = {
      inherit (cfg) enable;

      extraConfig = builtins.concatStringsSep "\n" [
        (pkgs.callPackage ./customrc.nix { })

        (optionalString (keyboardLayout == "colemak") ''
          "" AutoPairs{{{

          " disable shortcuts, <A-n> conflicts with Colemak movement
          let g:AutoPairsShortcutJump = ""

          " }}}
          "" Golang{{{
          ""

          " configure vim-go to show errors in the quickfix window and not the location list.
          let g:go_list_type = "quickfix"

          " disable the default mapping {if} and {af}, conflicts with Colemak
          " See mappings.vim for remapping
          let g:go_textobj_enabled = 0

          " disable go doc mappings
          let g:go_doc_keywordprg_enabled = 0

          " disable go def mappings
          let g:go_def_mapping_enabled = 0

          if has("autocmd")
            " Go
            au FileType go nmap <Leader>gc <Plug>(go-doc)
            au FileType go nmap <Leader>gd <Plug>(go-def)
            au FileType go nmap <Leader>sgd <Plug>(go-def-split)
            au FileType go nmap <Leader>vgd <Plug>(go-def-vertical)
            au FileType go nmap <Leader>gi <Plug>(go-info)
          endif

          " }}}
          "" Ruby{{{
          ""

          " disable the default mapping {if} and {af}, conflicts with Colemak
          " See mappings.vim for remapping
          let g:no_ruby_maps = 1

          " }}}
        '')
      ];

      plugins = with pkgs.vimPlugins; [
        # repeat # is this still needed?
        LanguageClient-neovim
        PreserveNoEOL
        ack-vim
        auto-pairs
        caw
        csv-vim
        direnv-vim
        easy-align
        easymotion
        emmet-vim
        fzf-vim
        fzfWrapper
        goyo # :Goyo for distraction-free writin
        gundo-vim
        multiple-cursors
        registers-nvim
        rhubarb # GitHub support for Fugitive
        sleuth # shiftwidth/expandtab settings. Replaces EditorConfig.
        surround
        traces-vim
        vim-airline
        vim-airline-themes
        vim-better-whitespace
        vim-eunuch
        vim-fugitive
        vim-gist
        vim-signify
        vim-speeddating
        vissort-vim
        webapi-vim # required for vim-gist
        zoomwintab-vim
        {
          plugin = nvim-lspconfig;
          config = ''
            -- Mappings.
            -- See `:help vim.diagnostic.*` for documentation on any of the below functions
            --local opts = { noremap=true, silent=true }
            --vim.api.nvim_set_keymap('n', '<space>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
            --vim.api.nvim_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
            --vim.api.nvim_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
            --vim.api.nvim_set_keymap('n', '<space>q', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)

            -- Use an on_attach function to only map the following keys
            -- after the language server attaches to the current buffer
            local on_attach = function(client, bufnr)
              -- Enable completion triggered by <c-x><c-o>
              vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

              -- Mappings.
              -- See `:help vim.lsp.*` for documentation on any of the below functions
              vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
              vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
              vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
              vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
              vim.api.nvim_buf_set_keymap(bufnr, 'n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
              vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
              vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
              vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
              vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
              vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
              vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
              vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
              vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
            end

            -- Use a loop to conveniently call 'setup' on multiple servers and
            -- map buffer local keybindings when the language server attaches
            --local servers = { 'pyright', 'rust_analyzer', 'tsserver' }
            local servers = { 'gopls' }
            for _, lsp in pairs(servers) do
              require('lspconfig')[lsp].setup {
                on_attach = on_attach,
                flags = {
                  -- This will be the default in neovim 0.7+
                  debounce_text_changes = 150,
                }
              }
            end
          '';
          type = "lua";
        }

        # treesitter, enable for all grammers
        (nvim-treesitter.withPlugins (plugins: pkgs.tree-sitter.allGrammars))
      ]
      ++ (optionals (keyboardLayout == "colemak") [ vim-colemak ]);
    };
  };
}
