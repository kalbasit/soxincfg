{ config, ... }:

let
  sopsFile = ./home.sops.yaml;
  homePath = config.home.homeDirectory;
in
{
  sops.gnupg.qubes-split-gpg = {
    enable = true;
    domain = "vault-gpg";
  };

  sops.secrets = {
    _aws_configure_profile_personal_sh = {
      inherit sopsFile;
      mode = "0500";
    };
    _config_swm_config_yaml_qubes = {
      inherit sopsFile;
      path = "${homePath}/.config/swm/config.yaml";
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
