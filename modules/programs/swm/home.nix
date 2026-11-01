{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.soxincfg.programs.swm;

  toml = pkgs.formats.toml { };

  inherit (cfg) name;

  # The prefix of the variables the manager passes its hooks: SWM_, MAKTAB_.
  envPrefix = lib.toUpper (lib.replaceStrings [ "-" ] [ "_" ] name);

  branchNameTemplate =
    if cfg.branchNameTemplate != null then
      cfg.branchNameTemplate
    else
      "user/${config.home.username}/{{.Name}}";

  # The manager finds its config under adrg/xdg's XDG_CONFIG_HOME, which on
  # macOS is ~/Library/Application Support unless the variable is set. The
  # files go there as links, so the directory itself stays a real one: the
  # manager also keeps its stories (and, without XDG_RUNTIME_DIR, its
  # sockets) there on macOS.
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;

  # A new story worktree gets the .envrc trust its canonical clone already
  # has, and its dev shell (pre-commit included) is built right away instead
  # of on the first interactive prompt.
  direnvHook = pkgs.writeShellApplication {
    name = "${name}-hook-direnv";
    runtimeInputs = [
      config.programs.direnv.package
      pkgs.diffutils
      pkgs.jq
    ];
    text = ''
      worktree_envrc="''$${envPrefix}_WORKTREE_PATH/.envrc"
      repo_envrc="''$${envPrefix}_REPO_PATH/.envrc"

      [[ -f $worktree_envrc ]] || exit 0

      if [[ ! -f $repo_envrc ]] || ! cmp -s "$worktree_envrc" "$repo_envrc"; then
        echo "${name}-hook-direnv: $worktree_envrc differs from the canonical clone's; run 'direnv allow' after reviewing it" >&2
        exit 0
      fi

      allowed="$(cd "''$${envPrefix}_REPO_PATH" && direnv status --json | jq -r '.state.foundRC.allowed // empty')"
      if [[ $allowed != 0 ]]; then
        echo "${name}-hook-direnv: $repo_envrc is not allowed; not allowing the worktree's copy" >&2
        exit 0
      fi

      direnv allow "''$${envPrefix}_WORKTREE_PATH"
      direnv exec "''$${envPrefix}_WORKTREE_PATH" true || echo "${name}-hook-direnv: loading $worktree_envrc failed" >&2
    '';
  };

  gitSpiceTrackHook = pkgs.writeShellApplication {
    name = "${name}-hook-git-spice-track";
    runtimeInputs = [
      pkgs.git
      pkgs.git-spice
      pkgs.jq
    ];
    text = ''
      cd "''$${envPrefix}_WORKTREE_PATH"
      # Skip repositories where git-spice is not initialized.
      git rev-parse --verify refs/spice/data >/dev/null 2>&1 || exit 0
      trunk="$(git cat-file -p refs/spice/data:repo | jq -r '.trunk')"
      exec gs branch track --base "$trunk"
    '';
  };

  hookFiles = lib.concatMapAttrs (
    event:
    lib.mapAttrs' (
      file: text:
      lib.nameValuePair "hooks/${event}.d/${file}" {
        inherit text;
        executable = true;
      }
    )
  ) cfg.hooks;

  # Every file below, relative to the manager's config directory.
  files = hookFiles // {
    "config.toml".source = toml.generate "${name}-config.toml" (
      lib.recursiveUpdate {
        code_root = cfg.codeRoot;
        default_story = cfg.defaultStory;
        plugins = {
          session = "tmux";
          vcs = "git";
          picker = "fzf";
          inherit (cfg) forges;
        };
        story.branch_name_template = branchNameTemplate;
      } cfg.settings
    );

    "session-tmux.toml".source = toml.generate "${name}-session-tmux.toml" {
      path = "{{.WorktreePath}}";
      windows = cfg.sessionWindows;
    };
  };

  claudeRuleFiles = lib.optionalAttrs (cfg.claudeRules != null) (
    lib.mapAttrs'
      (file: _: lib.nameValuePair ".claude/rules/${file}" { source = "${cfg.claudeRules}/${file}"; })
      (
        lib.filterAttrs (file: type: type != "directory" && lib.hasSuffix ".md" file) (
          builtins.readDir cfg.claudeRules
        )
      )
  );
in
{
  imports = [ ./options.nix ];

  config = lib.mkIf cfg.enable {
    home = {
      packages = [ cfg.package ];

      file =
        claudeRuleFiles
        // lib.optionalAttrs isDarwin (
          lib.mapAttrs' (n: v: lib.nameValuePair "Library/Application Support/${name}/${n}" v) files
        );
    };

    programs = {
      pet.snippets = lib.mkBefore [
        {
          description = "${name}-story-remove";
          command = "${name} story remove";
        }
      ];

      zsh.shellAliases.s = lib.mkDefault "${name} workspace open";
    };

    soxin.programs.tmux.extraConfig = lib.mkBefore ''
      bind s split-window -p 20 -v ${name} workspace open --kill-pane
    '';

    soxincfg.programs.swm.hooks.post-worktree-create = lib.mkMerge [
      (lib.mkIf cfg.direnvHook.enable {
        "10-direnv" = ''
          #!/bin/sh
          exec ${lib.getExe direnvHook}
        '';
      })

      (lib.mkIf cfg.gitSpiceTrackHook.enable {
        "20-git-spice-track" = ''
          #!/bin/sh
          exec ${lib.getExe gitSpiceTrackHook}
        '';
      })
    ];

    xdg.configFile = lib.mkIf (!isDarwin) (
      lib.mapAttrs' (n: v: lib.nameValuePair "${name}/${n}" v) files
    );
  };
}
