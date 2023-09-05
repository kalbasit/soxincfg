{ config, lib, mode, pkgs, ... }:

let
  inherit (lib)
    getBin
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
in
{
  config = mkIf cfg.enable {
    soxin.programs.neovim = {
      plugins = with pkgs.vimPlugins; [
        PreserveNoEOL
        caw
        csv-vim
        direnv-vim
        emmet-vim
        goyo # :Goyo for distraction-free writin
        rhubarb # GitHub support for Fugitive
        sleuth # shiftwidth/expandtab settings. Replaces EditorConfig.
        traces-vim
        vim-airline-themes
        vim-eunuch
        vim-go
        vim-nix
        vim-signify
        vim-speeddating
        vissort-vim

        {
          plugin = zoomwintab-vim;
          config = ''
            vim.keymap.set('n', '<Leader>zo', ':ZoomWinTabToggle<CR>')
          '';
          type = "lua";
        }

        {
          plugin = surround;
          config = ''
            vim.g.surround_no_mappings = 1

            -- Copied from https://github.com/tpope/vim-surround/blob/e49d6c2459e0f5569ff2d533b4df995dd7f98313/plugin/surround.vim#L578-L596
            -- TODO: complete as needed
            vim.keymap.set('n', 'ws', '<Plug>Csurround')
          '';
          type = "lua";
        }

        {
          plugin = multiple-cursors;
          config = ''
            vim.g.multi_cursor_use_default_mapping = 0

            -- Default mapping
            vim.g.multi_cursor_start_word_key      = '<C-n>'
            vim.g.multi_cursor_start_key           = 'g<C-n>'
            vim.g.multi_cursor_next_key            = '<C-n>'
            vim.g.multi_cursor_prev_key            = '<C-p>'
            vim.g.multi_cursor_skip_key            = '<C-x>'
            vim.g.multi_cursor_quit_key            = '<Esc>'
          '';
          type = "lua";
        }

        {
          plugin = gundo-vim;
          config = ''
            vim.keymap.set('n', '<Leader>go', ':GundoToggle<CR>')
          '';
          type = "lua";
        }

        {
          plugin = vim-gist;
          config = ''
            vim.g.gist_clip_command = '${getBin pkgs.xsel}/bin/xsel -bi'
            vim.g.gist_show_privates = 1
            vim.g.gist_post_private = 1
          '';
          type = "lua";
        }

        {
          plugin = auto-pairs;
          config =
            ''
              -- do not jump to the next line if there's only whitespace after the closing
              -- pair
              vim.g.AutoPairsMultilineClose = 0
            '' +
            (optionalString isColemak ''
              -- disable shortcuts, <A-n> conflicts with Colemak movement
              vim.gAutoPairsShortcutJump = ""
            '');
          type = "lua";
        }

        {
          plugin = easy-align;
          config = ''
            vim.keymap.set('v', 'ga', '<Plug>(EasyAlign)')
          '';
          type = "lua";
        }

        {
          plugin = easymotion;
          config = ''
            -- change the default prefix to \\
            vim.keymap.set(''', '\\\\', '<Plug>(easymotion-prefix)')
          '';
          type = "lua";
        }

        {
          plugin = vim-airline;
          config = ''
            -- show tabline
            vim.cmd 'let g:airline#extensions#tabline#enabled = 1'
          '';
          type = "lua";
        }

        {
          plugin = vim-better-whitespace;
          config = ''
            vim.g.better_whitespace_enabled = 1
            vim.g.strip_whitespace_on_save = 1
            vim.g.strip_whitespace_confirm = 0
            vim.cmd "let g:better_whitespace_filetypes_blacklist = ['gitsendemail', 'diff', 'gitcommit', 'unite', 'qf', 'help', 'mail']"
          '';
          type = "lua";
        }

        {
          plugin = vim-fugitive;
          config = ''
            -- ask Fugitive to not set any mappings
            vim.g.fugitive_no_maps = 1

            -- Delete certain buffers in order to not cluttering up the buffer list
            vim.api.nvim_create_autocmd('BufReadPost', {
              pattern = 'fugitive://*',
              command = 'set bufhidden=delete'
            })
          '';
          type = "lua";
        }
      ]
      ++ (optionals isColemak [ vim-colemak ]);
    };
  };
}
