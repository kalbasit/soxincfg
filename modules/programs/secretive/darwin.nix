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
  imports = [ ./options.nix ];

  config = mkIf cfg.enable {
    homebrew = {
      casks = [
        "secretive"
      ];
    };
  };
}
