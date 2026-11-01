{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkOption types;

  json = pkgs.formats.json { };

  pluginSrc = ./plugin;

  package = pkgs.writeShellScriptBin "sparse-worktree" ''
    exec ${pkgs.python3}/bin/python3 -I ${pluginSrc}/lib/sparse_worktree.py "$@"
  '';

  # Claude Code refuses local plugin sources reached through symlinks, so the plugin is
  # built as real files, its wrapper included.
  claudePlugin = pkgs.runCommand "sparse-worktrees-claude-plugin" { } ''
    mkdir -p $out/bin
    cp -r ${pluginSrc}/.claude-plugin ${pluginSrc}/hooks ${pluginSrc}/lib $out/
    cp -L ${package}/bin/sparse-worktree $out/bin/
  '';
in
{
  options.soxincfg.programs.sparse-worktree = {
    enable = mkEnableOption "sparse-worktree, which makes worktrees of large repositories sparse";

    repos = mkOption {
      type = types.attrsOf json.type;
      default = { };
      example = {
        "github.com/org/monorepo" = {
          dirs = [
            "build"
            "services/api"
          ];
          maxAutoAddFiles = 25000;
        };
      };
      description = ''
        Repositories whose new worktrees are sparse, keyed by `<host>/<owner>/<name>`. Each
        takes `dirs`, the cone to check out, and `maxAutoAddFiles`, the largest directory
        added automatically when a tool misses a path.
      '';
    };

    package = mkOption {
      type = types.package;
      readOnly = true;
      default = package;
      description = "The sparse-worktree command.";
    };

    claudePlugin = mkOption {
      type = types.package;
      readOnly = true;
      default = claudePlugin;
      description = ''
        The Claude Code plugin (`sparse-worktrees`) as a directory of real files, for a
        marketplace to copy. Its hooks widen the cone when a tool hits a missing path.
      '';
    };

    swmPlugin = {
      enable = mkEnableOption "the swm git plugin wrapper that creates sparse worktrees";

      package = mkOption {
        type = types.package;
        default = config.soxincfg.programs.swm.package;
        defaultText = lib.literalExpression "config.soxincfg.programs.swm.package";
        description = "swm package whose `swm-plugin-vcs-git` gets wrapped.";
      };
    };
  };
}
