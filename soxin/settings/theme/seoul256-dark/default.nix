{ mode, config, pkgs, lib, ... }:

with lib;
let

  neovimExtraKnownPlugins = pkgs.callPackage ./plugins.lib.nix { };

in
{
  config = mkIf (config.soxin.settings.theme == "seoul256") (mkMerge [
    (optionalAttrs (mode == "home-manager") {
      soxin.programs.neovim = {
        extraRC = mkBefore ''
          colorscheme seoul256
          let g:airline_theme='seoul256'
        '';

        extraKnownPlugins = neovimExtraKnownPlugins;

        extraPluginDictionaries = [{
          names = [
            "airline-seoul256-theme"
            "vim-color-seoul256"
          ];
        }];
      };

      xsession = optionalAttrs pkgs.stdenv.isLinux {
        windowManager.i3.config = {
          colors = {
            background = "#4e4e4e";

            focused = {
              border = "#5f865f";
              background = "#5f865f";
              text = "#e4e4e4";
              indicator = "#ffafaf";
              childBorder = "#285577";
            };

            focusedInactive = {
              border = "#4e4e4e";
              background = "#4e4e4e";
              text = "#d0d0d0";
              indicator = "#ffafaf";
              childBorder = "#5f676a";
            };

            unfocused = {
              border = "#4e4e4e";
              background = "#4e4e4e";
              text = "#87d7d7";
              indicator = "#87af87";
              childBorder = "#222222";
            };

            urgent = {
              border = "#ff0000";
              background = "#ff0000";
              text = "#e4e4e4";
              indicator = "#d68787";
              childBorder = "#900000";
            };
          };
        };
      };

      services.polybar.config."colors" = {
        background = "#5f865f";
        background-alt = "#87af87";
        foreground = "#e4e4e4";
        foreground-alt = "#626262";
        primary = "#ffafaf";
        secondary = "#5f676a";
        alert = "#ff0000";
      };

      programs.rofi.theme = "Adapta-Nokto";

      programs.termite = {
        backgroundColor = "#3a3a3a";
        foregroundColor = "#d0d0d0";
        colorsExtra = ''
          color0     = #4e4e4e
          color10    = #87af87
          color11    = #ffd787
          color12    = #add4fb
          color13    = #ffafaf
          color14    = #87d7d7
          color15    = #e4e4e4
          color1     = #d68787
          color2     = #5f865f
          color3     = #d8af5f
          color4     = #85add4
          color5     = #d7afaf
          color6     = #87afaf
          color7     = #d0d0d0
          color8     = #626262
          color9     = #d75f87
        '';
      };

      programs.taskwarrior.colorTheme = "solarized-dark-256";

      programs.tmux.extraConfig = ''
        set-option -g status-justify left
        set-option -g status-left-length 16
        set-option -g status-interval 60

        set-option -g status-left '#[bg=colour72] #[bg=colour237] #[bg=colour236] #{prefix_highlight} #[bg=colour235]#[fg=colour185] #h #[bg=colour236] '
        set-option -g status-right '#[bg=colour236] #[bg=colour237]#[fg=colour185] #[bg=colour235] #(date "+%a %b %d %H:%M") #[bg=colour236] #[bg=colour237] #[bg=colour72] '

        set-window-option -g window-status-format '#[bg=colour238]#[fg=colour107] #I #[bg=colour239]#[fg=colour110] #[bg=colour240]#W#[bg=colour239]#[fg=colour195]#F#[bg=colour238] '
        set-window-option -g window-status-current-format '#[bg=colour236]#[fg=colour215] #I #[bg=colour235]#[fg=colour167] #[bg=colour234]#W#[bg=colour235]#[fg=colour195]#F#[bg=colour236] '
        set-option -g status-style bg=colour237
        set-option -g pane-active-border-style fg=colour215
        set-option -g pane-border-style fg=colour185
      '';
    })
  ]);
}
