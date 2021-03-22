{ config, lib, mode, ... }:
with lib;
let
  yl_home = config.users.users.yl.home;
  owner = config.users.users.yl.name;
  sopsFile = ./home.sops.yaml;
in
mkMerge [
  (optionalAttrs (mode == "NixOS") {
    sops.secrets._aws_config = { inherit owner sopsFile; path = "${yl_home}/.aws/config"; };
    sops.secrets._aws_credentials = { inherit owner sopsFile; path = "${yl_home}/.aws/credentials"; };
    sops.secrets._config_pet_config_toml = { inherit owner sopsFile; path = "${yl_home}/.config/pet/config.toml"; };
    sops.secrets._config_pet_snippet_toml = { inherit owner sopsFile; path = "${yl_home}/.config/pet/snippet.toml"; };
    sops.secrets._config_remmina_remmina_pref = { inherit owner sopsFile; path = "${yl_home}/.config/remmina/remmina.pref"; };
    sops.secrets._config_swm_config_yaml = { inherit owner sopsFile; path = "${yl_home}/.config/swm/config.yaml"; };
    sops.secrets._config_tiny_config_yml = { inherit owner sopsFile; path = "${yl_home}/.config/tiny/config.yml"; };
    sops.secrets._docker_config_json = { inherit owner sopsFile; path = "${yl_home}/.docker/config.json"; };
    sops.secrets._gist = { inherit owner sopsFile; path = "${yl_home}/.gist"; };
    sops.secrets._gist_vim = { inherit owner sopsFile; path = "${yl_home}/.gist-vim"; };
    sops.secrets._gitconfig_secrets = { inherit owner sopsFile; path = "${yl_home}/.gitconfig.secrets"; };
    sops.secrets._github_token = { inherit owner sopsFile; path = "${yl_home}/.github_token"; };
    sops.secrets._jrnl_config = { inherit owner sopsFile; path = "${yl_home}/.jrnl_config"; };
    sops.secrets._local_share_remmina_my_network_vnc_athena_athena_admin_nasreddine_com_remmina = { inherit owner sopsFile; path = "${yl_home}/.local/share/remmina/my-network_vnc_athena_athena-admin-nasreddine-com.remmina"; };
    sops.secrets._local_share_remmina_my_network_vnc_athena_athena_general_nasreddine_com_remmina = { inherit owner sopsFile; path = "${yl_home}/.local/share/remmina/my-network_vnc_athena_athena-general-nasreddine-com.remmina"; };
    sops.secrets._local_share_remmina_my_network_vnc_poseidon_poseidon_admin_nasreddine_com_remmina = { inherit owner sopsFile; path = "${yl_home}/.local/share/remmina/my-network_vnc_poseidon_poseidon-admin-nasreddine-com.remmina"; };
    sops.secrets._local_share_remmina_my_network_vnc_poseidon_poseidon_general_nasreddine_com_remmina = { inherit owner sopsFile; path = "${yl_home}/.local/share/remmina/my-network_vnc_poseidon_poseidon-general-nasreddine-com.remmina"; };
    sops.secrets._local_share_remmina_my_network_vnc_vanya-macbook_remmina = { inherit owner sopsFile; path = "${yl_home}/.local/share/remmina/my-network_vnc_vanya-macbook.remmina"; };
    sops.secrets._local_share_remmina_my_network_vnc_vanya-macbook_ro_remmina = { inherit owner sopsFile; path = "${yl_home}/.local/share/remmina/my-network_vnc_vanya-macbook-ro.remmina"; };
    sops.secrets._netrc = { inherit owner sopsFile; path = "${yl_home}/.netrc"; };
    sops.secrets._ssh_config_include_myself = { inherit owner sopsFile; path = "${yl_home}/.ssh/config_include_myself"; };
    sops.secrets._zsh_profiles_opensource_zsh = { inherit owner sopsFile; path = "${yl_home}/.zsh/profiles/opensource.zsh"; };
    sops.secrets._zsh_profiles_personal_zsh = { inherit owner sopsFile; path = "${yl_home}/.zsh/profiles/personal.zsh"; };
  })

  (optionalAttrs (mode == "home-manager") {
    programs.ssh.extraConfig = ''
      Include ~/.ssh/config_include_myself
    '';
  })
]
