{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.soxincfg.programs.reclaim;

  reclaim = pkgs.writeShellApplication {
    name = "reclaim";
    bashOptions = [
      "nounset"
      "pipefail"
    ];
    runtimeInputs = [
      pkgs.coreutils
      pkgs.findutils
      pkgs.gawk
      pkgs.gh
      pkgs.git
      pkgs.gnugrep
      pkgs.jq
      cfg.storyManager.package
      pkgs.tmux
    ];
    runtimeEnv.RECLAIM_STORY_MANAGER = cfg.storyManager.name;
    text = builtins.readFile ./reclaim.sh;
  };
in
{
  imports = [ ./options.nix ];

  config = lib.mkIf cfg.enable {
    home.packages = [ reclaim ];
  };
}
