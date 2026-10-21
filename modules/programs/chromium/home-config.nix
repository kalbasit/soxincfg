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
      home.file.".surfingkeys.js".text = (
        let
          vars = {
            home_dir = "${config.home.homeDirectory}";
          };
        in
        # Substituted during evaluation, without a build, so a configuration of
        # one platform still evaluates on another.
        builtins.replaceStrings (map (name: "@${name}@") (
          builtins.attrNames vars
        )) (builtins.attrValues vars) (builtins.readFile ./surfingkeys.js)
      );
    })
  ]);
}
