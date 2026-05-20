{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.soxincfg.programs.swm;
in
{
  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.swm-full ];

    programs = {
      pet.snippets = lib.singleton {
        description = "swm-story-remove";
        command = "swm story remove";
      };

      zsh.shellAliases.s = "swm workspace open";
    };

    soxin.programs.tmux.extraConfig = ''
      bind s split-window -p 20 -v swm workspace open --kill-pane
    '';

    xdg.configFile."swm/config.toml".text =
      let
        laio-template = pkgs.writeText "laio.yaml" ''
          ---
          name: swm-pane-group

          # Resolved relative to the worktree path swm passes as cwd
          path: "{{ path }}"

          windows:
            - name: code
              panes:
                - commands:
                    - command: nvim

            - name: claude
              panes:
                - focus: true
                  commands:
                    - command: claude
                      args:
                        - --dangerously-skip-permissions

            - name: shell
              panes:
                - flex: 1
        '';
      in
      ''
        code_root     = "~/code"
        default_story = "_default"

        [plugins]
        session = "tmux"
        vcs     = "git"
        picker  = "fzf"
        forges  = ["github"]

        [plugins.config.session-tmux]
        pane_group_command = "laio start --file ${laio-template} --tmux-socket '{{tmux_socket}}' --replace-current-session --skip-attach --var path='{{worktree_path}}'"

        [story]
        branch_name_template = "user/wnasreddine/{{.Name}}"
      '';
  };
}
