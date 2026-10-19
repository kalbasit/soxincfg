{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.soxincfg.programs.autorandr;
in
{
  options.soxincfg.programs.autorandr = {
    enable = mkEnableOption "Configure Autorandr";
    postswitch.move-workspaces-to-main = mkOption {
      type = types.lines;
      default = "";
      description = ''
        Shell script added to the postswitch, after all of the workspaces have been moved to the main monitor.
      '';
    };
  };

  config = mkIf cfg.enable (mkMerge [
    { soxin.programs.autorandr.enable = true; }

    ({ })
  ]);
}
