{
  inputs,
  pkgs,
}:

let
  settings = {
    colorschemes.catppuccin = {
      enable = true;
      settings = {
        background = {
          light = "macchiato";
          dark = "mocha";
        };
        flavour = "macchiato"; # "latte", "mocha", "frappe", "macchiato" or raw lua code
      };
    };

    plugins.snacks.settings.dashboard.preset.header = ''
      ████████╗██████╗░██╗██████╗░██╗███╗░░██╗░░░████████╗███████╗░█████╗░██╗░░██╗
      ╚══██╔══╝██╔══██╗██║██╔══██╗██║████╗░██║░░░╚══██╔══╝██╔════╝██╔══██╗██║░░██║
      ░░░██║░░░██████╔╝██║██████╔╝██║██╔██╗██║░░░░░░██║░░░█████╗░░██║░░╚═╝███████║
      ░░░██║░░░██╔══██╗██║██╔═══╝░██║██║╚████║░░░░░░██║░░░██╔══╝░░██║░░██╗██╔══██║
      ░░░██║░░░██║░░██║██║██║░░░░░██║██║░╚███║██╗░░░██║░░░███████╗╚█████╔╝██║░░██║
      ░░░╚═╝░░░╚═╝░░╚═╝╚═╝╚═╝░░░░░╚═╝╚═╝░░╚══╝╚═╝░░░╚═╝░░░╚══════╝░╚════╝░╚═╝░░╚═╝
    '';
  };

  keymaps = {
    nvix.leader = ",";

    plugins = {
      # Use my colemak keybindings
      vim-colemak.enable = true;

      neo-tree = {
        # Disable the default keymappings
        settings = {
          use_default_mappings = false;

          # window.mappings = {
          #   "<CR>" = "open";
          #   "<esc>" = "revert_preview";
          #   P = {
          #     command = "toggle_preview";
          #     config = {
          #       use_float = true;
          #     };
          #   };
          #   l = "focus_preview";
          #   s = "open_split";
          #   S = "open_vsplit";
          #   t = "open_tabnew";
          #   R = "refresh";
          #   a = {
          #     command = "add";
          #     # some commands may take optional config options, see `:h neo-tree-mappings` for details
          #     config = {
          #       show_path = "none"; # "none", "relative", "absolute"
          #     };
          #   };
          #   A = "add_directory"; # also accepts the config.show_path and config.insert_as options.
          #   d = "delete";
          #   r = "rename";
          #   c = "copy_to_clipboard";
          #   x = "cut_to_clipboard";
          #   v = "paste_from_clipboard";
          #   q = "close_window";
          #   "?" = "show_help";
          #   "<" = "prev_source";
          #   ">" = "next_source";
          # };
        };
      };
    };
  };

  keymapHelpers.keymaps = [
    {
      mode = "n";
      key = "<leader>gf";
      # TODO: This action has a bug that it creates a file relative to Vim's
      # CWD as opposed to being relative to the buffer. My existing Nvim
      # suffers from the same bug, I'm leaving a note for myself to fix it.
      action = ":e <cfile><CR>";
      options = {
        desc = "Open file at cursor even if non-existing";
      };
    }
    {
      mode = "n";
      key = "<leader>=";
      action = ":normal! gg=G``<CR>";
      options = {
        desc = "Format the entire file";
      };
    }
    {
      mode = "n";
      key = "<leader>cd";
      action = ":lcd %:h<CR>";
      options = {
        desc = "Change to the directory containing the file in the buffer";
        silent = true;
      };
    }
    {
      mode = "n";
      key = "<leader>md";
      action = ":!mkdir -p %:p:h<CR>";
      options = {
        desc = "Create the directory containing the file in the buffer";
        silent = true;
      };
    }
    {
      mode = "n";
      key = "<leader><leader>";
      action = "<C-^>";
      options = {
        desc = "Swap to previous buffer";
      };
    }
    {
      # http://vimcasts.org/e/14
      mode = "n";
      key = "<leader>ew";
      action = ":e <C-R>=expand('%:h').'/'<CR>";
      options = {
        desc = "Open a file from the same directory in the current buffer";
      };
    }
    {
      # http://vimcasts.org/e/14
      mode = "n";
      key = "<leader>es";
      action = ":sp <C-R>=expand('%:h').'/'<CR>";
      options = {
        desc = "Open a file from the same directory in a horizontal split";
      };
    }
    {
      # http://vimcasts.org/e/14
      mode = "n";
      key = "<leader>ev";
      action = ":vsp <C-R>=expand('%:h').'/'<CR>";
      options = {
        desc = "Open a file from the same directory in a vertical split";
      };
    }
    {
      # http://vimcasts.org/e/14
      mode = "n";
      key = "<leader>et";
      action = ":tabe <C-R>=expand('%:h').'/'<CR>";
      options = {
        desc = "Open a file from the same directory in a new tab";
      };
    }
    {
      mode = "n";
      key = "gw";
      action = ''
        :s/\(\%#\w\+\)\(\_W\+\)\(\w\+\)/\3\2\1/<CR>`'
      '';
      options = {
        desc = "Swap two words";
        silent = true;
      };
    }
    {
      mode = "n";
      key = "<leader>fc";
      action = "<ESC>/\\v^[<=>]{7}( .*\|$)<CR>";
      options = {
        desc = "Find merge conflict markers";
        silent = true;
      };
    }
    {
      mode = "n";
      key = "<leader>hs";
      action = ":set hlsearch! hlsearch?<CR>";
      options = {
        desc = "Toggle hlsearch";
        silent = true;
      };
    }
    {
      mode = "n";
      key = "<leader>ww";
      action = ":wall<CR>";
      options = {
        desc = "Save all buffers";
        silent = true;
      };
    }
    {
      mode = "n";
      key = "<leader>wa";
      action = ":%bd<CR><CR>:Startup display<CR>";
      options = {
        desc = "Close all buffers";
        silent = true;
      };
    }
  ];

  commonExtensions = settings // keymaps // keymapHelpers;
in

{
  bare = inputs.nvix.packages.${pkgs.stdenv.hostPlatform.system}.bare.extend commonExtensions;

  core = inputs.nvix.packages.${pkgs.stdenv.hostPlatform.system}.core.extend commonExtensions;

  full = inputs.nvix.packages.${pkgs.stdenv.hostPlatform.system}.full.extend commonExtensions;
}
