{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.soxincfg.programs.swm;

  toml = pkgs.formats.toml { };

  branchNameTemplate =
    if cfg.branchNameTemplate != null then
      cfg.branchNameTemplate
    else
      "user/${config.home.username}/{{.Name}}";
in
{
  imports = [ ./options.nix ];

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    programs = {
      pet.snippets = lib.mkBefore [
        {
          description = "swm-story-remove";
          command = "swm story remove";
        }
      ];

      zsh.shellAliases.s = lib.mkDefault "swm workspace open";
    };

    soxin.programs.tmux.extraConfig = lib.mkBefore ''
      bind s split-window -p 20 -v swm workspace open --kill-pane
    '';

    xdg.configFile = {
      "swm/config.toml".source = toml.generate "swm-config.toml" (
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

      "swm/session-tmux.toml".source = toml.generate "swm-session-tmux.toml" {
        path = "{{.WorktreePath}}";
        windows = cfg.sessionWindows;
      };
    };
  };
}
