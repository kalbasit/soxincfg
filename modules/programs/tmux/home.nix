{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.soxincfg.programs.tmux;

  common = import ./common.nix { inherit config lib pkgs; };
in
{
  options.soxincfg.programs.tmux = {
    enable = mkEnableOption "programs.tmux";
  };

  config = mkIf cfg.enable (mkMerge [
    { soxin.programs.tmux = common.soxin; }

    # turn off sensibleOnTop
    # TODO: Remove this after 24.11 because it's now defaults to false
    { programs.tmux.sensibleOnTop = false; }

    { programs.tmux = common.programs; }
  ]);
}
