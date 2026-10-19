{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkIf mkMerge;

  inherit (pkgs) chromium;

  cfg = config.soxincfg.programs.chromium;
in
{
  config = mkIf cfg.enable (mkMerge [
    { home.packages = [ chromium ]; }

    (mkIf cfg.surfingkeys.enable {
      home.file.".surfingkeys.js".text = builtins.readFile (
        pkgs.replaceVars ./surfingkeys.js {
          home_dir = "${config.home.homeDirectory}";
        }
      );
    })
  ]);
}
