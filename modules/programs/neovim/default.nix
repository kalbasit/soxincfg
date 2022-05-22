{ config, lib, mode, pkgs, ... }:

let
  inherit (lib)
    concatStringsSep
    getBin
    mkEnableOption
    mkIf
    optionalString
    optionals
    ;

  cfg = config.soxincfg.programs.neovim;

  isColemak =
    let
      keyboardLayout = config.soxin.settings.keyboard.defaultLayout.console.keyMap;
    in
    keyboardLayout == "colemak";

  # TODO: extract to its own file
  treesitter-plugins = with pkgs.vimPlugins;[
    (nvim-treesitter.withPlugins (plugins: pkgs.tree-sitter.allGrammars))
    nvim-treesitter-context
  ];
in
{
  imports = [
    ./completion.nix
    ./lsp.nix
  ];

  options.soxincfg.programs.neovim = {
    enable = mkEnableOption "programs.neovim";
  };

  config = mkIf cfg.enable {
    soxin.programs.neovim = {
      inherit (cfg) enable;

      extraConfig = concatStringsSep "\n" [
        (pkgs.callPackage ./customrc.nix { })
      ];

      plugins = with pkgs.vimPlugins; [
        # repeat # is this still needed?

        PreserveNoEOL
        caw
        csv-vim
        direnv-vim
        emmet-vim
        goyo # :Goyo for distraction-free writin
        registers-nvim
        rhubarb # GitHub support for Fugitive
        sleuth # shiftwidth/expandtab settings. Replaces EditorConfig.
        traces-vim
        vim-airline-themes
        vim-eunuch
        vim-nix
        vim-signify
        vim-speeddating
        vissort-vim
        webapi-vim # required for vim-gist

        {
          plugin = zoomwintab-vim;
          config = ''
            nmap <Leader>zo :ZoomWinTabToggle<CR>
          '';
        }

        {
          plugin = surround;
          config = ''
            let g:surround_no_mappings = 1

            " Copied from https://github.com/tpope/vim-surround/blob/e49d6c2459e0f5569ff2d533b4df995dd7f98313/plugin/surround.vim#L578-L596
            " TODO: complete as needed
            nmap ws  <Plug>Csurround
          '';
        }

        {
          plugin = multiple-cursors;
          config = ''
            let g:multi_cursor_use_default_mapping=0

            " Default mapping
            let g:multi_cursor_start_word_key      = '<C-n>'
            let g:multi_cursor_start_key           = 'g<C-n>'
            let g:multi_cursor_next_key            = '<C-n>'
            let g:multi_cursor_prev_key            = '<C-p>'
            let g:multi_cursor_skip_key            = '<C-x>'
            let g:multi_cursor_quit_key            = '<Esc>'
          '';
        }

        {
          plugin = gundo-vim;
          config = ''
            nmap <Leader>go :GundoToggle<CR>
          '';
        }

        {
          plugin = vim-gist;
          config = ''
            let g:gist_clip_command = '${getBin pkgs.xsel}/bin/xsel -bi'
            let g:gist_show_privates = 1
            let g:gist_post_private = 1
          '';
        }

        {
          plugin = ack-vim;
          config = ''
            let g:ackprg = '${getBin pkgs.ag}/bin/ag --vimgrep --smart-case'
            cnoreabbrev ag Ack
            cnoreabbrev aG Ack
            cnoreabbrev Ag Ack
            cnoreabbrev AG Ack

            map <Leader>/ :Ack<space>
          '';
        }

        {
          plugin = auto-pairs;
          config =
            ''
              " do not jump to the next line if there's only whitespace after the closing
              " pair
              let g:AutoPairsMultilineClose = 0
            '' +
            (optionalString isColemak ''
              " disable shortcuts, <A-n> conflicts with Colemak movement
              let g:AutoPairsShortcutJump = ""
            '');
        }

        {
          plugin = easy-align;
          config = ''
            vmap ga <Plug>(EasyAlign)
          '';
        }

        {
          plugin = easymotion;
          config = ''
            " change the default prefix to \\
            map \\ <Plug>(easymotion-prefix)
          '';
        }

        {
          plugin = fzf-vim;
          config = ''
            " [Buffers] Jump to the existing window if possible
            let g:fzf_buffers_jump = 1

            let g:fzf_action = {
                  \ 'ctrl-t': 'tab split',
                  \ 'ctrl-s': 'split',
                  \ 'ctrl-v': 'vsplit' }

            function! s:fzf_statusline()
              " Override statusline as you like
              highlight fzf1 ctermfg=161 ctermbg=251
              highlight fzf2 ctermfg=23 ctermbg=251
              highlight fzf3 ctermfg=237 ctermbg=251
              setlocal statusline=%#fzf1#\ >\ %#fzf2#fz%#fzf3#f
            endfunction

            autocmd! User FzfStatusLine call <SID>fzf_statusline()

            " mapping for files and buffers
            nmap <Leader>f :Files<CR>
            nmap <Leader>b :Buffers<CR>

            " Mapping selecting mappings
            nmap <leader><tab> <plug>(fzf-maps-n)
            xmap <leader><tab> <plug>(fzf-maps-x)
            omap <leader><tab> <plug>(fzf-maps-o)

            " Insert mode completion
            imap <c-x><c-k> <plug>(fzf-complete-word)
            imap <c-x><c-f> <plug>(fzf-complete-path)
            imap <c-x><c-j> <plug>(fzf-complete-file-ag)
            imap <c-x><c-l> <plug>(fzf-complete-line)
          '';
        }

        {
          plugin = vim-airline;
          config = ''
            " show tabline
            let g:airline#extensions#tabline#enabled = 1
          '';
        }

        {
          plugin = vim-better-whitespace;
          config = ''
            let g:better_whitespace_enabled=1
            let g:strip_whitespace_on_save=1
            let g:strip_whitespace_confirm=0
            let g:better_whitespace_filetypes_blacklist=['gitsendemail', 'diff', 'gitcommit', 'unite', 'qf', 'help', 'mail']
          '';
        }

        {
          plugin = vim-fugitive;
          config = ''
            " ask Fugitive to not set any mappings
            let g:fugitive_no_maps = 1

            " Delete certain buffers in order to not cluttering up the buffer list
            au BufReadPost fugitive://* set bufhidden=delete
          '';
        }
      ]
      ++ treesitter-plugins
      ++ (optionals isColemak [ vim-colemak ]);
    };
  };
}
