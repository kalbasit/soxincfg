{ mode, config, pkgs, lib, soxin, ... }:

with lib;
let
  cfg = config.soxin.programs.neovim;

  extraRC =
    cfg.theme.extraRC
    + (import ./customrc.nix { inherit (pkgs) ag gocode xsel; inherit (lib) getBin; })
    + (optionalString (cfg.keyboardLayout == "colemak") ''
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
    '');

  start = with pkgs.vimPlugins; [
    vim-gist
    gundo-vim
    LanguageClient-neovim
    PreserveNoEOL
    ack-vim
    ale
    auto-pairs
    caw
    csv-vim
    deoplete-go
    deoplete-nvim
    direnv-vim
    easy-align
    easymotion
    editorconfig-vim
    emmet-vim
    fzf-vim
    fzfWrapper
    goyo
    multiple-cursors
    ncm2
    pig-vim
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
  ]
  ++ cfg.theme.plugins # load the colorscheme packages
  ++ (optionals (cfg.keyboardLayout == "colemak") [ vim-colemak ]);

  # NOTE: polyglot must be loaded manually because if it gets loaded
  # before vim-go and conflicts with it causing problems starting nvim.
  # See https://github.com/sheerun/vim-polyglot/issues/309
  opt = with pkgs.vimPlugins; [ polyglot ];
in
{
  options = {
    soxin.programs.neovim = soxin.lib.mkSoxinModule {
      inherit config;
      name = "neovim";
      includeKeyboardLayout = true;
      includeTheme = true;
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (optionalAttrs (mode == "NixOS") {
      programs.neovim = {
        enable = true;

        # make it a default editor
        defaultEditor = true;

        # Create a symlink of nvim to vi and vim
        viAlias = true;
        vimAlias = true;

        # Add support for NodeJS, Python 2 and 3 as well as Ruby
        # withNodeJs = true;
        # withPython3 = true;
        withRuby = true;

        # Add the Python's neovim plugin
        # extraPython3Packages = ps: with ps; [ pynvim ];

        configure = {
          customRC = extraRC;
          packages.myVimPackage = { inherit start opt; };
        };
      };
    })

    (optionalAttrs (mode == "home-manager") {
      home.sessionVariables = { EDITOR = "nvim"; };
      programs.neovim = {
        enable = true;

        # Create a symlink of nvim to vi and vim
        viAlias = true;
        vimAlias = true;

        # Add support for NodeJS, Python 2 and 3 as well as Ruby
        withNodeJs = true;
        withPython3 = true;
        withRuby = true;

        # Add the Python's neovim plugin
        extraPython3Packages = ps: with ps; [ pynvim ];

        extraConfig = extraRC;
        plugins =
          (map (p: { plugin = p; }) start)
          ++ (map (p: { plugin = p; optional = true; }) opt);
      };
    })
  ]);
}
