{ config, lib, mode, pkgs, ... }:

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