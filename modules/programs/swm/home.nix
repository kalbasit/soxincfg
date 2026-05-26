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
    home.packages = [
      pkgs.laio
      pkgs.swm-full
    ];

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

    xdg.configFile."swm/config.toml".text = ''
      code_root     = "~/code"
      default_story = "_default"

      [plugins]
      session = "tmux"
      vcs     = "git"
      picker  = "fzf"
      forges  = ["github"]


      [story]
      branch_name_template = "user/wnasreddine/{{.Name}}"
    '';

    xdg.configFile."swm/session-tmux.toml".text = ''
      path = "{{.WorktreePath}}"

      [[windows]]
      name = "code"

        [[windows.panes]]
        commands = ["nvim"]

      [[windows]]
      name = "claude"

        [[windows.panes]]
        focus = true
        commands = ["claude --dangerously-skip-permissions"]

      [[windows]]
      name = "shell"

        [[windows.panes]]
        flex = 1
    '';
  };
}
