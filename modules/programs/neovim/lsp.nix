{ config, lib, mode, pkgs, inputs, ... }:

let
  inherit (lib)
    mkEnableOption
    mkIf
    optionals
    ;

  cfg = config.soxincfg.programs.neovim;
in
{
  options.soxincfg.programs.neovim.lsp = {
    enable = mkEnableOption "programs.neovim.lsp.enable";
    lightbulb = mkEnableOption "Enable Light Bulb";
    # TODO: merge these with Soxin
    languages = {
      bash = mkEnableOption "Enable Bash Language support";
      clang = mkEnableOption "Enable C/C++ with clang";
      css = mkEnableOption "Enable css support";
      docker = mkEnableOption "Enable docker support";
      go = mkEnableOption "Enable Go Language support";
      html = mkEnableOption "Enable html support";
      json = mkEnableOption "Enable JSON";
      nix = mkEnableOption "Enable NIX Language support";
      python = mkEnableOption "Enable lsp python support";
      tex = mkEnableOption "Enable tex support";
      typescript = mkEnableOption "Enable Typescript/Javascript support";
      vimscript = mkEnableOption "Enable lsp vimscript support";
      yaml = mkEnableOption "Enable yaml support";
    };
  };

  config = mkIf cfg.lsp.enable {
    soxin.programs.neovim = {
      plugins = with pkgs.vimPlugins; [
        (mkIf cfg.lsp.lightbulb {
          plugin = nvim-lightbulb;
          config = ''
            require'nvim-lightbulb'.update_lightbulb {
              sign = {
                enabled = true,
                priority = 10,
              },
              float = {
                enabled = false,
                text = "💡",
                win_opts = {},
              },
              virtual_text = {
                enable = false,
                text = "💡",
              },
              status_text = {
                enabled = false,
                text = "💡",
                text_unavailable = ""
              }
            }
          '';
          type = "lua";
        })

        # TODO: Merge this with the one below. I only did this because I have
        # config in two different languages.
        {
          plugin = nvim-lspconfig;
          config = ''
            " Use <Tab> and <S-Tab> to navigate through popup menu
            inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
            inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

            set foldmethod=expr
            set foldlevel=10
            set foldexpr=nvim_treesitter#foldexpr()

            nnoremap K <cmd>lua vim.lsp.buf.hover()<CR>
            nnoremap gD <cmd>lua vim.lsp.buf.declaration()<CR>
            nnoremap gd <cmd>lua vim.lsp.buf.definition()<CR>
            nnoremap gi <cmd>lua vim.lsp.buf.implementation()<CR>
            nnoremap <leader>ca <cmd>lua vim.lsp.buf.code_action()<cr>
            nnoremap <leader>rn <cmd>lua vim.lsp.buf.rename()<cr>
            nnoremap <leader>f <cmd>lua vim.lsp.buf.formatting()<CR>
            nnoremap <leader>k <cmd>lua vim.lsp.diagnostic.goto_prev()<CR>
            nnoremap <leader>j <cmd>lua vim.lsp.diagnostic.goto_next()<CR>
          '';
        }

        {
          plugin = nvim-lspconfig;
          config = ''
            local lspconfig = require'lspconfig'

            --Tree sitter config
            require('nvim-treesitter.configs').setup {
              highlight = {
                enable = true,
                disable = {},
              },
              rainbow = {
                enable = true,
                extended_mode = true,
              },
               autotag = {
                enable = true,
              },
              context_commentstring = {
                enable = true,
              },
              incremental_selection = {
                enable = true,
                keymaps = {
                  init_selection = "gnn",
                  node_incremental = "grn",
                  scope_incremental = "grc",
                  node_decremental = "grm",
                },
              },
            }

            ${if cfg.completion.enable then ''
              local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
            '' else ""}

            ${if cfg.lsp.languages.bash then ''
              lspconfig.bashls.setup{
                ${if cfg.completion.enable then "capabilities = capabilities;" else ""}
                cmd = {"${pkgs.nodePackages.bash-language-server}/bin/bash-language-server", "start"}
              }
            '' else ""}

            ${if cfg.lsp.languages.clang then ''
              lspconfig.clangd.setup{
                ${if cfg.completion.enable then "capabilities = capabilities;" else ""}
                cmd = {'${pkgs.clang-tools}/bin/clangd', '--background-index'};
                filetypes = { "c", "cpp", "objc", "objcpp" };
              }
            '' else ""}

            ${if cfg.lsp.languages.css then ''
              lspconfig.cssls.setup{
                ${if cfg.completion.enable then "capabilities = capabilities;" else ""}
                cmd = {'${pkgs.nodePackages.vscode-css-languageserver-bin}/bin/css-languageserver', '--stdio' };
                filetypes = { "css", "scss", "less" };
              }
            '' else ""}

            ${if cfg.lsp.languages.docker then ''
              lspconfig.dockerls.setup{
                ${if cfg.completion.enable then "capabilities = capabilities;" else ""}
                cmd = {'${pkgs.nodePackages.dockerfile-language-server-nodejs}/bin/docker-language-server', '--stdio' }
              }
            '' else ""}

            ${if cfg.lsp.languages.go then ''
              lspconfig.gopls.setup{
                ${if cfg.completion.enable then "capabilities = capabilities;" else ""}
                cmd = {'${pkgs.gopls}/bin/gopls'}
              }
            '' else ""}

            ${if cfg.lsp.languages.html then ''
              lspconfig.html.setup{
                ${if cfg.completion.enable then "capabilities = capabilities;" else ""}
                cmd = {'${pkgs.nodePackages.vscode-html-languageserver-bin}/bin/html-languageserver', '--stdio' };
                filetypes = { "html", "css", "javascript" };
              }
            '' else ""}

            ${if cfg.lsp.languages.json then ''
              lspconfig.jsonls.setup{
                ${if cfg.completion.enable then "capabilities = capabilities;" else ""}
                cmd = {'${pkgs.nodePackages.vscode-json-languageserver-bin}/bin/json-languageserver', '--stdio' };
                filetypes = { "json", "html", "css", "javascript" };
              }
            '' else ""}

            ${if cfg.lsp.languages.nix then ''
              lspconfig.rnix.setup{
                ${if cfg.completion.enable then "capabilities = capabilities;" else ""}
                cmd = {"${pkgs.rnix-lsp}/bin/rnix-lsp"}
              }
            '' else ""}

            ${if cfg.lsp.languages.python then ''
              lspconfig.pyright.setup{
                ${if cfg.completion.enable then "capabilities = capabilities;" else ""}
                cmd = {"${pkgs.nodePackages.pyright}/bin/pyright-langserver", "--stdio"}
              }
            '' else ""}

            ${if cfg.lsp.languages.tex then ''
              lspconfig.texlab.setup{
                ${if cfg.completion.enable then "capabilities = capabilities;" else ""}
                cmd = {'${pkgs.texlab}/bin/texlab'}
              }
            '' else ""}

            ${if cfg.lsp.languages.typescript then ''
              lspconfig.tsserver.setup{
                ${if cfg.completion.enable then "capabilities = capabilities;" else ""}
                cmd = {'${pkgs.nodePackages.typescript-language-server}/bin/typescript-language-server', '--stdio' }
              }
            '' else ""}

            ${if cfg.lsp.languages.vimscript then ''
              lspconfig.vimls.setup{
                ${if cfg.completion.enable then "capabilities = capabilities;" else ""}
                cmd = {'${pkgs.nodePackages.vim-language-server}/bin/vim-language-server', '--stdio' }
              }
            '' else ""}

            ${if cfg.lsp.languages.yaml then ''
              lspconfig.vimls.setup{
                ${if cfg.completion.enable then "capabilities = capabilities;" else ""}
                cmd = {'${pkgs.nodePackages.yaml-language-server}/bin/yaml-language-server', '--stdio' }
              }
            '' else ""}
          '';
          type = "lua";
        }

        {
          plugin = which-key-nvim;
          config = ''
            local wk = require("which-key")
            wk.register({
              g = {
                D = {"Go to declaration"},
                d = {"Go to definition"},
              }
            }, {});
            wk.register({
              f = {
                name = "file",
                f = {"Find file"},
                r = {"Open Recent"},
                b = {"Open Buffers"},
              },
            },{ prefix = "<leader>" })
          '';
          type = "lua";
        }
      ]
      ++ optionals (cfg.completion.enable) [
        cmp-nvim-lsp
      ];
    };
  };
}
