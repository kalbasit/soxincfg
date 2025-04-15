{
  config,
  ...
}:

let
  homePath = config.soxincfg.settings.users.user.home;
  owner = config.soxincfg.settings.users.user.name;
  sopsFile = ./home.sops.yaml;
in
{
  config = {
    sops.secrets = {
      _aws_configure_profile_personal_sh = {
        inherit owner sopsFile;
        mode = "0500";
      };
      _config_remmina_remmina_pref = {
        inherit owner sopsFile;
        path = "${homePath}/.config/remmina/remmina.pref";
      };
      _config_swm_config_yaml = {
        inherit owner sopsFile;
        path = "${homePath}/.config/swm/config.yaml";
      };
      _config_tiny_config_yml = {
        inherit owner sopsFile;
        path = "${homePath}/.config/tiny/config.yml";
      };
      _gist = {
        inherit owner sopsFile;
        path = "${homePath}/.gist";
      };
      _gist_vim = {
        inherit owner sopsFile;
        path = "${homePath}/.gist-vim";
      };
      _gitconfig_secrets = {
        inherit owner sopsFile;
        path = "${homePath}/.gitconfig.secrets";
      };
      _github_token = {
        inherit owner sopsFile;
        path = "${homePath}/.github_token";
      };
      _jrnl_config = {
        inherit owner sopsFile;
        path = "${homePath}/.jrnl_config";
      };
      _local_share_remmina_my_network_vnc_athena_tailscale_nasreddine_com_remmina = {
        inherit owner sopsFile;
        path = "${homePath}/.local/share/remmina/my_network_vnc_athena_tailscale_nasreddine_com.remmina";
      };
      _local_share_remmina_my_network_vnc_vanya-macbook_remmina = {
        inherit owner sopsFile;
        path = "${homePath}/.local/share/remmina/my-network_vnc_vanya-macbook.remmina";
      };
      _local_share_remmina_my_network_vnc_vanya-macbook_ro_remmina = {
        inherit owner sopsFile;
        path = "${homePath}/.local/share/remmina/my-network_vnc_vanya-macbook-ro.remmina";
      };
      _netrc = {
        inherit owner sopsFile;
        path = "${homePath}/.netrc";
      };
      _ssh_config_include_personal = {
        inherit owner sopsFile;
        path = "${homePath}/.ssh/config_include_personal";
      };
      _ssh_per-host_bitbucket_org_rsa = {
        inherit owner sopsFile;
        path = "${homePath}/.ssh/per-host/bitbucket.org_rsa";
      };
      _ssh_per-host_cronus_ed25519 = {
        inherit owner sopsFile;
        path = "${homePath}/.ssh/per-host/cronus_ed25519";
      };
      _ssh_per-host_gitlab_com_rsa = {
        inherit owner sopsFile;
        path = "${homePath}/.ssh/per-host/gitlab.com_rsa";
      };
      _ssh_per-host_hermes-gl-mt3000_bigeye-bushi_ts_net_ed25519 = {
        inherit owner sopsFile;
        path = "${homePath}/.ssh/per-host/hermes-gl-mt3000.bigeye-bushi.ts.net_ed25519";
      };
      _ssh_per-host_serial_nasreddine_com_rsa = {
        inherit owner sopsFile;
        path = "${homePath}/.ssh/per-host/serial.nasreddine.com_rsa";
      };
      _ssh_per-host_unifi_nasreddine_com_rsa = {
        inherit owner sopsFile;
        path = "${homePath}/.ssh/per-host/unifi.nasreddine.com_rsa";
      };
      _zsh_profiles_opensource_zsh = {
        inherit owner sopsFile;
        path = "${homePath}/.zsh/profiles/opensource.zsh";
      };
      _zsh_profiles_personal_zsh = {
        inherit owner sopsFile;
        path = "${homePath}/.zsh/profiles/personal.zsh";
      };
    };
  };
}
