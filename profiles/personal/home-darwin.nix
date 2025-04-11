{ config, ... }:

let
  sopsFile = ./home.sops.yaml;
  homePath = config.home.homeDirectory;
in
{
  sops.secrets = {
    _aws_configure_profile_personal_sh = {
      inherit sopsFile;
      mode = "0500";
    };
    _config_swm_config_yaml_darwin = {
      inherit sopsFile;
      path = "${homePath}/Library/Application Support/swm/config.yaml";
    };
    _config_tiny_config_yml = {
      inherit sopsFile;
      path = "${homePath}/.config/tiny/config.yml";
    };
    _gist = {
      inherit sopsFile;
      path = "${homePath}/.gist";
    };
    _gist_vim = {
      inherit sopsFile;
      path = "${homePath}/.gist-vim";
    };
    _gitconfig_secrets = {
      inherit sopsFile;
      path = "${homePath}/.gitconfig.secrets";
    };
    _github_token = {
      inherit sopsFile;
      path = "${homePath}/.github_token";
    };
    _jrnl_config = {
      inherit sopsFile;
      path = "${homePath}/.jrnl_config";
    };
    _kube_config = { inherit sopsFile; };
    _kube_configure_profile_personal_sh = {
      inherit sopsFile;
      mode = "700";
    };
    _netrc = {
      inherit sopsFile;
      path = "${homePath}/.netrc";
    };
    _ssh_config_include_personal = {
      inherit sopsFile;
      path = "${homePath}/.ssh/config_include_personal";
    };
    _ssh_per-host_bitbucket_org_rsa = {
      inherit sopsFile;
      path = "${homePath}/.ssh/per-host/bitbucket.org_rsa";
    };
    _ssh_per-host_cronus_ed25519 = {
      inherit sopsFile;
      path = "${homePath}/.ssh/per-host/cronus_ed25519";
    };
    _ssh_per-host_gitlab_com_rsa = {
      inherit sopsFile;
      path = "${homePath}/.ssh/per-host/gitlab.com_rsa";
    };
    _ssh_per-host_hermes-gl-mt3000_bigeye-bushi_ts_net_ed25519 = {
      inherit sopsFile;
      path = "${homePath}/.ssh/per-host/hermes-gl-mt3000.bigeye-bushi.ts.net_ed25519";
    };
    _ssh_per-host_serial_nasreddine_com_rsa = {
      inherit sopsFile;
      path = "${homePath}/.ssh/per-host/serial.nasreddine.com_rsa";
    };
    _ssh_per-host_unifi_nasreddine_com_rsa = {
      inherit sopsFile;
      path = "${homePath}/.ssh/per-host/unifi.nasreddine.com_rsa";
    };
    _zsh_profiles_opensource_zsh = {
      inherit sopsFile;
      path = "${homePath}/.zsh/profiles/opensource.zsh";
    };
    _zsh_profiles_personal_zsh = {
      inherit sopsFile;
      path = "${homePath}/.zsh/profiles/personal.zsh";
    };
  };
}
