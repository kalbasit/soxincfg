{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.soxincfg.programs.maktab;

  # maktab finds its config, session-tmux.toml and hooks under adrg/xdg's
  # XDG_CONFIG_HOME, which on macOS is ~/Library/Application Support unless
  # the variable is set, and nothing here sets it. swm only found ~/.config on
  # saturn through a hand-made `Application Support/swm -> ~/.config/swm`
  # link. The files go where maktab looks instead, as links into the store,
  # so the directory itself stays a real one: maktab keeps its stories (and,
  # without XDG_RUNTIME_DIR, its sockets) in the same place on macOS. Linux
  # resolves ~/.config, home-manager's xdg.configHome.
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;

  # Every file below, relative to maktab's config directory.
  files =
    lib.concatMapAttrs (
      event:
      lib.mapAttrs' (
        name: text:
        lib.nameValuePair "hooks/${event}.d/${name}" {
          inherit text;
          executable = true;
        }
      )
    ) cfg.hooks
    // {
      # The same code_root swm uses: the two share it, and the cutover moves
      # swm's stories over rather than recreating them.
      "config.toml".text = ''
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

      "session-tmux.toml".text = ''
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
in
{
  config = lib.mkIf cfg.enable {
    home.packages = [
      # maktab and its plugins; `mk` is a link to maktab in the same package.
      pkgs.maktab-full

      # What a worker in a maktab pane reports with (`majlis reply`, `done`,
      # ...). On every host with maktab, because any of them may run workers.
      pkgs.majlis
    ];

    programs = {
      pet.snippets = lib.singleton {
        description = "maktab-story-remove";
        command = "mk story remove";
      };

      zsh.shellAliases.s = "mk workspace open";
    };

    soxin.programs.tmux.extraConfig = ''
      bind s split-window -p 20 -v mk workspace open --kill-pane
    '';

    home.file = lib.mkIf isDarwin (
      lib.mapAttrs' (n: v: lib.nameValuePair "Library/Application Support/maktab/${n}" v) files
    );

    xdg.configFile = lib.mkIf (!isDarwin) (
      lib.mapAttrs' (n: v: lib.nameValuePair "maktab/${n}" v) files
    );
  };
}
