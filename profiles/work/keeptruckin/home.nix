{ config, lib, mode, pkgs, ... }:

let
  inherit (lib)
    mkIf
    ;
in
{
  config = mkIf config.soxincfg.programs.ssh.enable {
    home.file = {
      ".ssh/per-host/ktdev.io_rsa.pub".text = ''
        ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCzZHKtYtJZMp2ZeSHazWzQdzPVbRioYSGqXDTwh83bMGHvGr47ZaYR46qbCbAPdmLtRxKQhOUFuMJM0vrkv46T6KeZVNaQ9sz5J4mV/Mp4k9UG7Rz5sScMgLy8+7HWQp5UgyiU36XxbjXUwgleWiX9WajJoad6x1b+H8KbOb/7inqePfH3ceFnZcefIH5YgFQR3nvLsmpAaGtF+349YhKmAwyH5WLoLwYMGv1VkOHTP/vPUbHxqSufZg7U/IhcVX6xCvrfwRPkbMv3a1BFHS/uVFU8srDPIxNlytlw1dzcTCAyo7SS/mzoGsC3VdV3EOnjCDAmBPiVGyOTSLnmvY6ulFIyW0xSQuE5C+kJA3JqKqsMgT/++OVChZAlVBjfXaVtBPHNE2gKLJWI2kuDOeOuVXqr6a5wv6xEtAH7lbvdI5aYspFjAQYr0TpznFhRfTGAcc0BeuQ4tXCSkG/l4hj22H2h62L1Rf0Ca9QeeKEM69wxjUvxUFVwQVSjCRRQiu9DBxSNH/o8ygNbqYbwjdRAYI4yr9jVHcPRAEF1kx1BteXaWKKW5Nw03Ctj8sjag7vu22qSdpZAYihu1S8RCmN9nbOuT3iMrZQTyCxMPkxPmNTf2b9D5JrD9wmGrTW2LIU+Nsim6oano4wiWlAoux7VLgCSdwEhIYHYX9O+WKx0Mw== ktdev.io
      '';
    };

    programs.ssh = {
      extraConfig = ''
        Include ~/.ssh/config_include_work_keeptruckin
      '';
    };

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
