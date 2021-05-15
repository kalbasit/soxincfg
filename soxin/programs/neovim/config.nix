{ config
, extraRC ? ""
, extraKnownPlugins ? { }
, extraPluginDictionaries ? [ ]
, pkgs
, viAlias ? true
, vimAlias ? true
, withNodeJs ? true
, withPython3 ? true
, withRuby ? true
}:

with pkgs.lib;
let
  keyboardLayout =
    let
      dl = config.soxin.settings.keyboard.defaultLayout.x11;
    in
    if dl.variant == "colemak" then "colemak"
    else if dl.layout == "fw" && dl.variant == "befo" then "bepo"
    else if dl.layout == "us" && dl.variant == "intl" then "qwerty_intl"
    else if dl.layout == "us" && dl.variant == "" then "qwerty"
    else throw "I'm not sure what to do with the keyboard layout ${dl}";
in
{
  inherit viAlias vimAlias withNodeJs withPython3 withRuby;

  extraPython3Packages = ps: with ps; [ pynvim ];

  configure = {
    customRC =
      builtins.concatStringsSep " " [
        (builtins.readFile (pkgs.substituteAll {
          src = ./init.vim;

          ag_bin = "${getBin pkgs.ag}/bin/ag";
          gocode_bin = "${getBin pkgs.gocode}/bin/gocode";
          xsel_bin = "${getBin pkgs.xsel}/bin/xsel";
        }))

        # TODO: Do this better!
        (builtins.readFile (./keyboard_layouts + "/${keyboardLayout}.vim"))

        extraRC
      ];

    vam.knownPlugins = pkgs.vimPlugins // extraKnownPlugins;
    vam.pluginDictionaries = extraPluginDictionaries ++ [
      {
        names =
          [
            "Gundo"
            "LanguageClient-neovim"
            "PreserveNoEOL"
            "ack-vim"
            "ale"
            "auto-pairs"
            "caw"
            "csv-vim"
            "direnv-vim"
            "easy-align"
            "easymotion"
            "editorconfig-vim"
            "emmet-vim"
            "fzf-vim"
            "fzfWrapper"
            "goyo"
            "multiple-cursors"
            "ncm2"
            "nerdtree"
            # getting an error
            # "nerdtree-git-plugin"
            "pig-vim"
            "repeat"
            "rhubarb"
            "sleuth"
            "surround"
            "traces-vim"
            "vim-airline"
            "vim-airline-themes"
            "vim-better-whitespace"
            "vim-clang-format"
            "vim-eunuch"
            "vim-fugitive"
            # "vim-gist"
            "vim-markdown"
            "vim-scala"
            "vim-signify"
            "vim-speeddating"
            "vim-terraform"
            "vimtex"
            "vissort-vim"
            "zoomwintab-vim"

            # NOTE: Keep vim-go before PolyGlot. If PolyGlot is loaded first, vim-go will fail with the error `E117: Unknown function: go#config#VersionWarning`.
            # See https://github.com/sheerun/vim-polyglot/issues/309
            "vim-go"
            "polyglot"

            ## DeoPlete completion support
            "deoplete-nvim"

            # Golang support
            "deoplete-go"

            # TODO(#152): vim-bazel is broken.
            # "vim-maktaba"
            # "vim-bazel"

            # Typescript support
            # "vim-typescript"    # TODO: https://github.com/kalbasit/dotfiles/issues/15
            "yats-vim"
          ]
          ++ (optionals (keyboardLayout == "colemak") [ "vim-colemak" ]);
      }
    ];
  };
}
