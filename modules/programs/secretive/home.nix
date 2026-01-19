{
  config,
  lib,
  pkgs,
  hostType,
  ...
}:

let
  inherit (lib) mkIf;

  cfg = config.soxincfg.programs.secretive;
in
{
  config = mkIf (cfg.enable && hostType == "nix-darwin") {
    home.packages = [ pkgs.secretive ];
  };
}
