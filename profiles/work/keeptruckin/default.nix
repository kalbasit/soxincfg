{ config, home-manager, lib, mode, pkgs, ... }:

with lib;

{
  config = mkMerge [
    {
      soxin.programs.rbrowser.browsers = {
        "vivaldi@keeptruckin" = home-manager.lib.hm.dag.entryAfter [ "vivaldi@personal" ] { };
        "firefox@keeptruckin" = home-manager.lib.hm.dag.entryAfter [ "vivaldi@keeptruckin" ] { };
        "chromium@keeptruckin" = home-manager.lib.hm.dag.entryAfter [ "firefox@keeptruckin" ] { };
      };
    }

    (optionalAttrs (mode == "NixOS") (
      let
        yl_home = config.users.users.yl.home;
        owner = config.users.users.yl.name;
        sopsFile = ./secrets.sops.yaml;
      in
      {
        # Add the extra hosts
        networking.extraHosts = ''
          127.0.0.1 docker.keeptruckin.dev docker.keeptruckin.work
        '';

        nix = {
          binaryCaches = [ "http://cache.nixos.org" "https://nix-cache.corp.ktdev.io" ];
          binaryCachePublicKeys = [ "nix-cache.corp.ktdev.io:/xiDfugzrYzUtdUEIvdYBHy48O0169WYHYb/zMdWgLA=" ];
        };

        networking.networkmanager.packages = with pkgs; [ networkmanager-fortisslvpn ];

        sops.secrets._aws_configure_profile_keeptruckin_sh = { inherit owner sopsFile; mode = "0500"; };
        sops.secrets._config_ktmr_ansible_vault_passwd = { inherit owner sopsFile; path = "${yl_home}/.config/ktmr/ansible-vault.passwd"; };
        sops.secrets._config_ktmr_config_nix = { inherit owner sopsFile; path = "${yl_home}/.config/ktmr/config.nix"; };
        sops.secrets._config_mark = { inherit owner sopsFile; path = "${yl_home}/.config/mark"; };
        sops.secrets._etc_NetworkManager_system-connections_KeepTruckin-Lahore-PK-Office-VPN_nmconnection = { inherit sopsFile; path = "/etc/NetworkManager/system-connections/KeepTruckin-Lahore-PK-Office-VPN.nmconnection"; };
        sops.secrets._etc_NetworkManager_system-connections_KeepTruckin-VPN_nmconnection = { inherit sopsFile; path = "/etc/NetworkManager/system-connections/KeepTruckin-VPN.nmconnection"; };
        sops.secrets._etc_NetworkManager_system-connections_KeepTruckin_nmconnection = { inherit sopsFile; path = "/etc/NetworkManager/system-connections/KeepTruckin.nmconnection"; };
        sops.secrets._local_share_remmina_keeptruckin_vnc_mac-devprod_remmina = { inherit owner sopsFile; path = "${yl_home}/.local/share/remmina/keeptruckin_vnc_mac-devprod.remmina"; };
        sops.secrets._local_share_remmina_my-network_vnc_test-mac-1_test-mac-1-general-nasreddine-com_remmina = { inherit owner sopsFile; path = "${yl_home}/.local/share/remmina/my-network_vnc_test-mac-1_test-mac-1-general-nasreddine-com.remmina"; };
        sops.secrets._ssh_config_include_work_keeptruckin = { inherit owner sopsFile; path = "${yl_home}/.ssh/config_include_work_keeptruckin"; };
        sops.secrets._zsh_profiles_keeptruckin_admin_zsh = { inherit owner sopsFile; path = "${yl_home}/.zsh/profiles/keeptruckin.admin.zsh"; };
        sops.secrets._zsh_profiles_keeptruckin_playground_zsh = { inherit owner sopsFile; path = "${yl_home}/.zsh/profiles/keeptruckin.playground.zsh"; };
        sops.secrets._zsh_profiles_keeptruckin_zsh = { inherit owner sopsFile; path = "${yl_home}/.zsh/profiles/keeptruckin.zsh"; };
      }
    ))

    (mkIf config.soxincfg.programs.ssh.enable (optionalAttrs (mode == "home-manager") {
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
              rbrowser --profile "$profile" --browser "firefox" --new-window "https://k2labs.atlassian.net/browse/$story"
            '';
          in
          "exec --no-startup-id ${openJira}";
      };
    }))
  ];
}
