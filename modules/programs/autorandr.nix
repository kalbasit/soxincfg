{ config, lib, mode, pkgs, ... }:

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

    (optionalAttrs (mode == "home-manager") {
      programs.autorandr.hooks.postswitch.move-workspaces-to-main = ''
        set -euo pipefail

        # Make sure that i3 is running
        if [[ "$( ${getBin pkgs.i3}/bin/i3-msg -t get_outputs | ${getBin pkgs.jq}/bin/jq -r '.[] | select(.active == true) | .name' | wc -l )" -eq 1 ]]; then
          echo "no other monitor, bailing out"
          exit 0
        fi

        # Figure out the identifier of the main monitor
        readonly main_monitor="$( ${getBin pkgs.i3}/bin/i3-msg -t get_outputs | ${getBin pkgs.jq}/bin/jq -r '.[] | select(.active == true and .primary == true) | .name' )"

        # Get the list of workspaces that are not on the main monitor
        readonly workspaces=( $(${getBin pkgs.i3}/bin/i3-msg -t get_workspaces | ${getBin pkgs.jq}/bin/jq -r '.[] | select(.output != "''${main_monitor}") | .name') )

        # Move all workspaces over
        for workspace in "''${workspaces[@]}"; do
          ${getBin pkgs.i3}/bin/i3-msg "workspace ''${workspace}; move workspace to output ''${main_monitor}"
        done
      '' + cfg.postswitch.move-workspaces-to-main;
    })
  ]);
}
