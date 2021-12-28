{ config, soxincfg, ... }:

let
  yl_home = config.users.users.yl.home;
  owner = config.users.users.yl.name;
  sopsFile = ./home.sops.yaml;
in
{
  config = {
    sops.secrets = {
      _aws_configure_profile_personal_sh = { inherit owner sopsFile; mode = "0500"; };
      _config_pet_config_toml = { inherit owner sopsFile; path = "${yl_home}/.config/pet/config.toml"; };
      _config_pet_snippet_toml = { inherit owner sopsFile; path = "${yl_home}/.config/pet/snippet.toml"; };
      _config_remmina_remmina_pref = { inherit owner sopsFile; path = "${yl_home}/.config/remmina/remmina.pref"; };
      _config_swm_config_yaml = { inherit owner sopsFile; path = "${yl_home}/.config/swm/config.yaml"; };
      _config_tiny_config_yml = { inherit owner sopsFile; path = "${yl_home}/.config/tiny/config.yml"; };
      _docker_config_json = { inherit owner sopsFile; path = "${yl_home}/.docker/config.json"; };
      _gist = { inherit owner sopsFile; path = "${yl_home}/.gist"; };
      _gist_vim = { inherit owner sopsFile; path = "${yl_home}/.gist-vim"; };
      _gitconfig_secrets = { inherit owner sopsFile; path = "${yl_home}/.gitconfig.secrets"; };
      _github_token = { inherit owner sopsFile; path = "${yl_home}/.github_token"; };
      _jrnl_config = { inherit owner sopsFile; path = "${yl_home}/.jrnl_config"; };
      _local_share_remmina_my-network_vnc_mancave-tv-pc_mancave-tv-pc-general-nasreddine-com_remmina = { inherit owner sopsFile; path = "${yl_home}/.local/share/remmina/my-network_vnc_mancave-tv-pc_mancave-tv-pc-general.remmina"; };
      _local_share_remmina_my_network_vnc_athena_athena_admin_nasreddine_com_remmina = { inherit owner sopsFile; path = "${yl_home}/.local/share/remmina/my-network_vnc_athena_athena-admin-nasreddine-com.remmina"; };
      _local_share_remmina_my_network_vnc_athena_athena_general_nasreddine_com_remmina = { inherit owner sopsFile; path = "${yl_home}/.local/share/remmina/my-network_vnc_athena_athena-general-nasreddine-com.remmina"; };
      _local_share_remmina_my_network_vnc_poseidon_poseidon_admin_nasreddine_com_remmina = { inherit owner sopsFile; path = "${yl_home}/.local/share/remmina/my-network_vnc_poseidon_poseidon-admin-nasreddine-com.remmina"; };
      _local_share_remmina_my_network_vnc_poseidon_poseidon_general_nasreddine_com_remmina = { inherit owner sopsFile; path = "${yl_home}/.local/share/remmina/my-network_vnc_poseidon_poseidon-general-nasreddine-com.remmina"; };
      _local_share_remmina_my_network_vnc_vanya-macbook_remmina = { inherit owner sopsFile; path = "${yl_home}/.local/share/remmina/my-network_vnc_vanya-macbook.remmina"; };
      _local_share_remmina_my_network_vnc_vanya-macbook_ro_remmina = { inherit owner sopsFile; path = "${yl_home}/.local/share/remmina/my-network_vnc_vanya-macbook-ro.remmina"; };
      _netrc = { inherit owner sopsFile; path = "${yl_home}/.netrc"; };
      _ssh_config_include_myself = { inherit owner sopsFile; path = "${yl_home}/.ssh/config_include_myself"; };
      _ssh_per-host_bitbucket_org_rsa = { inherit owner sopsFile; path = "${yl_home}/.ssh/per-host/bitbucket.org_rsa"; };
      _ssh_per-host_gitlab_com_rsa = { inherit owner sopsFile; path = "${yl_home}/.ssh/per-host/gitlab.com_rsa"; };
      _ssh_per-host_serial_nasreddine_com_rsa = { inherit owner sopsFile; path = "${yl_home}/.ssh/per-host/serial.nasreddine.com_rsa"; };
      _zsh_profiles_opensource_zsh = { inherit owner sopsFile; path = "${yl_home}/.zsh/profiles/opensource.zsh"; };
      _zsh_profiles_personal_zsh = { inherit owner sopsFile; path = "${yl_home}/.zsh/profiles/personal.zsh"; };
    };

    soxincfg.settings.users = {
      # allow my user to access secrets
      groups = [ "keys" ];

      inherit (soxincfg.vars) users;
    };
  };
}
