{
  config,
  lib,
  mode,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.soxincfg.programs.tmux;

  keyboardLayout = config.soxin.settings.keyboard.defaultLayout.console.keyMap;

  tmuxVimAwarness =
    let
      isVim = pkgs.writeShellScript "isVim.sh" ''
        ps -o state= -o comm= -t '#{pane_tty}' | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|l?n?vim?x?)(diff)?$'
      '';
    in
    ''
      # Smart pane switching with awareness of Vim splits.
      # See: https://github.com/christoomey/vim-tmux-navigator
      is_vim="${isVim}"
      bind-key -n M-n if-shell "$is_vim" "send-keys M-n"  "select-pane -L"
      bind-key -n M-e if-shell "$is_vim" "send-keys M-e"  "select-pane -D"
      bind-key -n M-i if-shell "$is_vim" "send-keys M-i"  "select-pane -U"
      bind-key -n M-o if-shell "$is_vim" "send-keys M-o"  "select-pane -R"
    '';

  colemakBindings = ''
    #
    # Colemak binding
    #

    # cursor movement
    bind-key -r -T copy-mode-vi n send -X cursor-left
    bind-key -r -T copy-mode-vi e send -X cursor-down
    bind-key -r -T copy-mode-vi i send -X cursor-up
    bind-key -r -T copy-mode-vi o send -X cursor-right

    # word movement
    bind-key -r -T copy-mode-vi u send -X next-word-end
    bind-key -r -T copy-mode-vi U send -X next-space-end
    bind-key -r -T copy-mode-vi y send -X next-word
    bind-key -r -T copy-mode-vi Y send -X next-space
    bind-key -r -T copy-mode-vi l send -X previous-word
    bind-key -r -T copy-mode-vi L send -X previous-space

    # search
    bind-key -r -T copy-mode-vi k send -X search-again
    bind-key -r -T copy-mode-vi K send -X search-reverse

    # visual mode
    bind-key -r -T copy-mode-vi a send -X begin-selection

    # yank
    bind-key -r -T copy-mode-vi c send -X copy-selection-and-cancel
    bind-key -r -T copy-mode-vi C send -X copy-selection

    # char search
    bind-key -r -T copy-mode-vi p command-prompt -1 -p "jump to forward" "send -X jump-to-forward \"%%%\""
    bind-key -r -T copy-mode-vi P command-prompt -1 -p "jump to backward" "send -X jump-to-backward \"%%%\""

    # Change window move behavior
    bind . command-prompt "swap-window -t '%%'"
    bind > command-prompt "move-window -t '%%'"

    # More straight forward key bindings for splitting
    unbind %
    bind h split-window -h
    unbind '"'
    bind v split-window -v

    # The shortcut is set to <t> which overrides the default mapping for clock mode
    bind T clock-mode

    # Bind pane selection and pane resize for Vim Bindings in Colemak!
    bind n select-pane -L
    bind e select-pane -D
    bind i select-pane -U
    bind o select-pane -R
    bind -r N resize-pane -L 5
    bind -r E resize-pane -D 5
    bind -r I resize-pane -U 5
    bind -r O resize-pane -R 5
  '';

  copyPaste = optionalString pkgs.stdenv.isLinux ''
    # copy/paste to system clipboard
    bind-key C-p run "${pkgs.tmux}/bin/tmux save-buffer - | ${pkgs.gist}/bin/gist -f tmux.sh-session --no-private | ${pkgs.xsel}/bin/xsel --clipboard -i && ${pkgs.libnotify}/bin/notify-send -a Tmux 'Buffer saved as public gist' 'Tmux buffer was saved as Gist, URL in clipboard' --icon=dialog-information"
    bind-key C-g run "${pkgs.tmux}/bin/tmux save-buffer - | ${pkgs.gist}/bin/gist -f tmux.sh-session --private | ${pkgs.xsel}/bin/xsel --clipboard -i && ${pkgs.libnotify}/bin/notify-send -a Tmux 'Buffer saved as private gist' 'Tmux buffer was saved as Gist, URL in clipboard' --icon=dialog-information"
    bind-key C-c run "${pkgs.tmux}/bin/tmux save-buffer - | ${pkgs.xsel}/bin/xsel --clipboard -i"
    bind-key C-v run "${pkgs.xsel}/bin/xsel --clipboard -o | ${pkgs.tmux}/bin/tmux load-buffer; ${pkgs.tmux}/bin/tmux paste-buffer"
  '';
in
{
  options.soxincfg.programs.tmux = {
    enable = mkEnableOption "programs.tmux";
  };

  config = mkIf cfg.enable (mkMerge [
    {
      soxin.programs.tmux = {
        inherit (cfg) enable;

        extraConfig =
          tmuxVimAwarness
          + ''
            #
            # Settings
            #

            # tmux messages are displayed for 4 seconds
            set-option -g display-time 4000

            # don't allow the terminal to rename windows
            set-window-option -g allow-rename off

            # show the current command in the border of the pane
            set-option -g pane-border-status "top"
            set-option -g pane-border-format "#P: #{pane_current_command}"

            # Terminal emulator window title
            set-option -g set-titles on
            set-option -g set-titles-string '#S:#I.#P #W'

            # Status Bar
            set-option -g status on

            # refresh 'status-left' and 'status-right' more often
            set-option -g status-interval 5

            # emacs key bindings in tmux command prompt (prefix + :) are better than
            # vi keys, even for vim users
            set-option -g status-keys emacs

            # focus events enabled for terminals that support them
            set-option -g focus-events on

            # Notifying if other windows has activities
            #setw -g monitor-activity off
            set-option -g visual-activity on

            # Trigger the bell for any action
            set-option -g bell-action any
            set-option -g visual-bell off

            # No Mouse!
            set-option -g mouse off

            # Do not update the environment, keep everything from what it was
            # started with except for my ZSH_PROFILE.
            set-option -g update-environment "ZSH_PROFILE"

            # Remove internal environment variables of nix-darwin/home-manager
            setenv -gu __NIX_DARWIN_SET_ENVIRONMENT_DONE
            setenv -gu __HM_SESS_VARS_SOURCED
            setenv -gu __HM_ZSH_SESS_VARS_SOURCED

            # Last active window
            bind C-t last-window
            bind C-r switch-client -l
            # bind C-n next-window
            bind C-n switch-client -p
            bind C-o switch-client -n

            # fuzzy client selection
            bind s split-window -p 20 -v ${pkgs.nur.repos.kalbasit.swm}/bin/swm tmux switch-client --kill-pane
          ''
          + copyPaste
          + optionalString (keyboardLayout == "colemak") colemakBindings;

        plugins = with pkgs.tmuxPlugins; [
          logging
          prefix-highlight
          fzf-tmux-url
          tmux-thumbs
        ];
      };
    }

    # turn off sensibleOnTop
    # TODO: Remove this after 24.11 because it's now defaults to false
    (optionalAttrs (mode == "home-manager") { programs.tmux.sensibleOnTop = false; })

    (optionalAttrs (mode == "NixOS" || mode == "home-manager") {
      programs.tmux = {
        clock24 = true;
        customPaneNavigationAndResize = keyboardLayout != "colemak";
        escapeTime = 0;
        historyLimit = 10000;
        keyMode = "vi";
        secureSocket = pkgs.stdenv.isLinux;
        shortcut = "t";

        terminal =
          if pkgs.stdenv.isLinux then
            "tmux-256color"
          else if pkgs.stdenv.isDarwin then
            "screen-256color"
          else
            "screen";
      };
    })
  ]);
}
