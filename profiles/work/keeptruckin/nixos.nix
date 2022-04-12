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

  sops.secrets = {
    _aws_configure_profile_keeptruckin_sh = { inherit owner sopsFile; mode = "0500"; };
    _config_ktmr_ansible_vault_passwd = { inherit owner sopsFile; path = "${yl_home}/.config/ktmr/ansible-vault.passwd"; };
    _config_ktmr_config_nix = { inherit owner sopsFile; path = "${yl_home}/.config/ktmr/config.nix"; };
    _config_mark = { inherit owner sopsFile; path = "${yl_home}/.config/mark"; };
    _etc_NetworkManager_system-connections_KeepTruckin-Lahore-PK-Office-VPN_nmconnection = { inherit sopsFile; path = "/etc/NetworkManager/system-connections/KeepTruckin-Lahore-PK-Office-VPN.nmconnection"; };
    _etc_NetworkManager_system-connections_KeepTruckin-VPN_nmconnection = { inherit sopsFile; path = "/etc/NetworkManager/system-connections/KeepTruckin-VPN.nmconnection"; };
    _etc_NetworkManager_system-connections_KeepTruckin_nmconnection = { inherit sopsFile; path = "/etc/NetworkManager/system-connections/KeepTruckin.nmconnection"; };
    _local_share_remmina_keeptruckin_vnc_mac-devprod_remmina = { inherit owner sopsFile; path = "${yl_home}/.local/share/remmina/keeptruckin_vnc_mac-devprod.remmina"; };
    _local_share_remmina_keeptruckin_vnc_poseidon_tailscale_nasreddine_com_remmina = { inherit owner sopsFile; path = "${yl_home}/.local/share/remmina/keeptruckin_vnc_poseidon_tailscale_nasreddine_com.remmina"; };
    _local_share_remmina_keeptruckin_vnc_semele_tailscale_nasreddine_com_remmina = { inherit owner sopsFile; path = "${yl_home}/.local/share/remmina/keeptruckin_vnc_semele_tailscale_nasreddine_com.remmina"; };
    _local_share_remmina_keeptruckin_vnc_saturn_tailscale_nasreddine_com_remmina = { inherit owner sopsFile; path = "${yl_home}/.local/share/remmina/keeptruckin_vnc_saturn_tailscale_nasreddine_com.remmina"; };
    _ssh_per-host_ktdev_io_rsa = { inherit owner sopsFile; path = "${yl_home}/.ssh/per-host/ktdev.io_rsa"; };
    _ssh_config_include_work_keeptruckin = { inherit owner sopsFile; path = "${yl_home}/.ssh/config_include_work_keeptruckin"; };
    _zsh_profiles_keeptruckin_admin_zsh = { inherit owner sopsFile; path = "${yl_home}/.zsh/profiles/keeptruckin.admin.zsh"; };
    _zsh_profiles_keeptruckin_playground_zsh = { inherit owner sopsFile; path = "${yl_home}/.zsh/profiles/keeptruckin.playground.zsh"; };
    _zsh_profiles_keeptruckin_zsh = { inherit owner sopsFile; path = "${yl_home}/.zsh/profiles/keeptruckin.zsh"; };
  };
}
