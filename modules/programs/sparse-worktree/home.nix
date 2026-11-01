{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.soxincfg.programs.sparse-worktree;

  # Put first on PATH for swm's git plugin only: `git worktree add` in a configured repo becomes
  # a sparse worktree, every other git call goes straight to the real git.
  gitShim = pkgs.writeShellScriptBin "git" ''
    export SPARSE_WORKTREE_SHIM_DIR="''${0%/*}"
    exec ${cfg.package}/bin/sparse-worktree git "$@"
  '';

  # swm looks for plugins in $XDG_DATA_HOME/swm/plugins/<name>/ before PATH.
  swmVcsGit = pkgs.writeShellScript "swm-plugin-vcs-git" ''
    export PATH=${gitShim}/bin:$PATH
    exec ${cfg.swmPlugin.package}/bin/swm-plugin-vcs-git "$@"
  '';
in
{
  imports = [ ./options.nix ];

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        home.packages = [ cfg.package ];

        xdg.configFile."sparse-worktree/config.json".text = builtins.toJSON { inherit (cfg) repos; };
      }

      (lib.mkIf cfg.swmPlugin.enable {
        xdg.dataFile."swm/plugins/git/swm-plugin-vcs-git".source = swmVcsGit;
      })
    ]
  );
}
