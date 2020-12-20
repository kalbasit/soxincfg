{ mode, config, pkgs, lib, ... }:

with lib;
let
  cfg = config.soxin.programs.autorandr;
in
{
  options = {
    soxin.programs.autorandr = {
      enable = mkEnableOption "Whether to enable autorandr.";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (optionalAttrs (mode == "NixOS") {
      services.autorandr.enable = true;
    })

    (optionalAttrs (mode == "home-manager") {
      programs.autorandr = {
        enable = true;

        hooks = {
          postswitch = mkMerge [
            {
              "move-workspaces-to-main" = ''
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
              '';
            }

            (optionalAttrs config.soxin.services.xserver.windowManager.bar.enable {
              "restart-polybar" = ''
                set -euo pipefail

                systemctl --user restart polybar.service
              '';
            })
          ];
        };
      };
    })
  ]);
}
