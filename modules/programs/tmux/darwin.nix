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
  ]);
}
