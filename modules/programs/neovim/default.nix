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
        LanguageClient-neovim
        PreserveNoEOL
        ack-vim
        # ale
        auto-pairs
        caw
        csv-vim
        # deoplete-go
        # deoplete-nvim
        direnv-vim
        easy-align
        easymotion
        editorconfig-vim
        emmet-vim
        fzf-vim
        fzfWrapper
        goyo
        gundo-vim
        multiple-cursors
        ncm2
        pig-vim
        registers-nvim
        repeat
        rhubarb
        sleuth
        surround
        traces-vim
        vim-airline
        vim-airline-themes
        vim-better-whitespace
        vim-clang-format
        vim-eunuch
        vim-fugitive
        vim-gist
        vim-go
        vim-markdown
        vim-scala
        vim-signify
        vim-speeddating
        vim-terraform
        vimtex
        vissort-vim
        webapi-vim # required for Gist
        yats-vim
        zoomwintab-vim

        # NOTE: polyglot must be loaded manually because if it gets loaded
        # before vim-go and conflicts with it causing problems starting nvim.
        # See https://github.com/sheerun/vim-polyglot/issues/309
        { plugin = polyglot; optional = true; }
      ]
      ++ (optionals (keyboardLayout == "colemak") [ vim-colemak ]);
    };
  };
}
