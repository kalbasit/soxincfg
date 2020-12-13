{ mode, config, pkgs, lib, ... }:

with lib;
let
  cfg = config.soxin.programs.tmux;
in
{
  options = recursiveUpdate
    {
      soxin.programs.tmux = {
        enable = mkEnableOption "Whether to enable tmux.";

        extraConfig = mkOption {
          type = types.lines;
          default = "";
          description = "Extra tmux configuration.";
        };

        tmuxConfig = mkOption {
          type = types.attrs;
          default = { };
          description = "tmux configuration passed to programs.tmux.";
        };
      };
    }

    (optionalAttrs (mode == "NixOS") {
      programs.tmux = {
        plugins = mkOption {
          type = with types; listOf package;
          default = [ ];
          description = ''
            List of tmux plugins to be included at the end of your tmux
            configuration. The sensible plugin, however, is defaulted to run at
            the top of your configuration.
            This option is not used when set inside a NixOS configuration.
          '';
        };
      };
    });

  config = {
    soxin.programs.tmux = {
      tmuxConfig =
        let
          tmuxVimAwarness = ''
            # Smart pane switching with awareness of Vim splits.
            # See: https://github.com/christoomey/vim-tmux-navigator
            is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
                | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?)(diff)?$'"
            bind-key -n M-n if-shell "$is_vim" "send-keys M-n"  "select-pane -L"
            bind-key -n M-e if-shell "$is_vim" "send-keys M-e"  "select-pane -D"
            bind-key -n M-i if-shell "$is_vim" "send-keys M-i"  "select-pane -U"
            bind-key -n M-o if-shell "$is_vim" "send-keys M-o"  "select-pane -R"
          '';

          copyPaste =
            optionalString pkgs.stdenv.isLinux ''
              # copy/paste to system clipboard
              bind-key C-p run "${pkgs.tmux}/bin/tmux save-buffer - | ${pkgs.gist}/bin/gist -f tmux.sh-session --no-private | ${pkgs.xsel}/bin/xsel --clipboard -i && ${pkgs.libnotify}/bin/notify-send -a Tmux 'Buffer saved as public gist' 'Tmux buffer was saved as Gist, URL in clipboard' --icon=dialog-information"
              bind-key C-g run "${pkgs.tmux}/bin/tmux save-buffer - | ${pkgs.gist}/bin/gist -f tmux.sh-session --private | ${pkgs.xsel}/bin/xsel --clipboard -i && ${pkgs.libnotify}/bin/notify-send -a Tmux 'Buffer saved as private gist' 'Tmux buffer was saved as Gist, URL in clipboard' --icon=dialog-information"
              bind-key C-c run "${pkgs.tmux}/bin/tmux save-buffer - | ${pkgs.xsel}/bin/xsel --clipboard -i"
              bind-key C-v run "${pkgs.xsel}/bin/xsel --clipboard -o | ${pkgs.tmux}/bin/tmux load-buffer; ${pkgs.tmux}/bin/tmux paste-buffer"
            '';
        in
        {
          enable = true;

          plugins = with pkgs.tmuxPlugins; [
            logging
            prefix-highlight
            fzf-tmux-url
            resurrect
          ];

          clock24 = true;
          customPaneNavigationAndResize = true;
          escapeTime = 0;
          historyLimit = 10000;
          keyMode = "vi";
          secureSocket = pkgs.stdenv.isLinux;
          shortcut = "t";

          extraConfig = ''
            ${tmuxVimAwarness}

            #
            # Settings
            #

            # don't allow the terminal to rename windows
            set-window-option -g allow-rename off

            # show the current command in the border of the pane
            set -g pane-border-status "top"
            set -g pane-border-format "#P: #{pane_current_command}"

            # Terminal emulator window title
            set -g set-titles on
            set -g set-titles-string '#S:#I.#P #W'

            # Status Bar
            set-option -g status on

            # Notifying if other windows has activities
            #setw -g monitor-activity off
            set -g visual-activity on

            # Trigger the bell for any action
            set-option -g bell-action any
            set-option -g visual-bell off

            # No Mouse!
            set -g mouse off

            # Do not update the environment, keep everything from what it was started with except for my ZSH_PROFILE
            set -g update-environment "ZSH_PROFILE"

            # Last active window
            bind C-t last-window
            bind C-r switch-client -l
            # bind C-n next-window
            bind C-n switch-client -p
            bind C-o switch-client -n

            ${copyPaste}

            ${optionalString pkgs.stdenv.isLinux ''set  -g default-terminal "tmux-256color"''}

            ${cfg.extraConfig}

            set -g @resurrect-capture-pane-contents 'on'
          '';
        };
    };

    programs.tmux = cfg.tmuxConfig;
  };
}
