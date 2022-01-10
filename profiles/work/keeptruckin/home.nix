{ config, lib, mode, pkgs, ... }:

let
  inherit (lib)
    mkIf
    ;
in
{
  config = mkIf config.soxincfg.programs.ssh.enable {
    programs.ssh.extraConfig = ''
      Include ~/.ssh/config_include_work_keeptruckin
    '';

    xsession.windowManager.i3.config.keybindings = {
      "Mod4+j" =
        let
          openJira = with pkgs; writeShellScript "open-jira.sh" ''
            set -euo pipefail

            active_workspace="$(i3-msg -t get_workspaces 2>/dev/null | ${jq}/bin/jq -r '.[] | if .focused == true then .name else empty end')"
            if ! echo  "$active_workspace" | grep -q '.*@.*'; then
              ${libnotify}/bin/notify-send 'Open Jira' "No story is currently in progress"
              exit 1
            fi

            profile="$(echo "$active_workspace" | cut -d@ -f1)"
            if [[ "$profile" != "keeptruckin" ]]; then
              ${libnotify}/bin/notify-send 'Open Jira' "The profile $profile is not supported, only keeptruckin is. Sorry!"
              exit 1
            fi

            story="$(echo "$active_workspace" | cut -d@ -f2)"
            rbrowser --profile "$profile" --browser "vivaldi" --new-window "https://k2labs.atlassian.net/browse/$story"
          '';
        in
        "exec --no-startup-id ${openJira}";
    };
  };
}
