{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkIf;

  cfg = config.soxincfg.programs.secretive;
in
{
  config = mkIf cfg.enable {
    homebrew = {
      casks = [
        "secretive"
      ];
    };
  };
}
