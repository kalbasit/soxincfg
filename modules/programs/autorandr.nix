{
  config,
  lib,
  mode,
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

    (optionalAttrs (mode == "home-manager") {
      programs.autorandr.hooks.postswitch.move-workspaces-to-main = ''
        set -euo pipefail

        # Make sure that i3 is running
        if [[ "$( ${getBin pkgs.i3}/bin/i3-msg -t get_outputs | ${getBin pkgs.jq}/bin/jq -r '.[] | select(.active == true) | .name' | wc -l )" -eq 1 ]]; then
          >&2 echo "no other monitor, bailing out"
          exit 0
        fi

        # Figure out the identifier of the main monitor
        readonly main_monitor="$( ${getBin pkgs.i3}/bin/i3-msg -t get_outputs | ${getBin pkgs.jq}/bin/jq -r '.[] | select(.active == true and .primary == true) | .name' )"
        >&2 echo "main_monitor=$main_monitor"

        # Get the list of workspaces that are not on the main monitor
        readonly workspaces=( $(${getBin pkgs.i3}/bin/i3-msg -t get_workspaces | ${getBin pkgs.jq}/bin/jq -r '.[] | select(.output != "''${main_monitor}") | .name') )
        >&2 echo "workspaces=''${workspaces[*]}"

        # Move all workspaces over
        for workspace in "''${workspaces[@]}"; do
          >&2 echo "Getting the output of the workspace '$workspace'"
          workspace_output="$(${getBin pkgs.i3}/bin/i3-msg -t get_workspaces | ${getBin pkgs.jq}/bin/jq -r ".[] | select(.name == \"$workspace\").output")"
          if [[ "$workspace_output" != "$main_monitor" ]]; then
            >&2 echo "The workspace '$workspace' is currently on output '$workspace_output', moving it to '$main_monitor'"
            >&2 echo "Moving the workspace '$workspace' to the main monitor"
            ${getBin pkgs.i3}/bin/i3-msg "workspace ''${workspace}; move workspace to output $main_monitor"
          else
            >&2 echo "The workspace '$workspace' is currently on the main output '$main_monitor'"
          fi
        done
      ''
      + cfg.postswitch.move-workspaces-to-main
      + ''
        # Go to my personal workspace
        ${getBin pkgs.i3}/bin/i3-msg "workspace personal";
      '';
    })
  ]);
}
