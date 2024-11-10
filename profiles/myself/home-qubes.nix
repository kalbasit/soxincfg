{ config, ... }:

let
  sopsFile = ./home.sops.yaml;
  yl_home = config.home.homeDirectory;
in
{
  sops.gnupg.qubes-split-gpg = { enable = true; domain = "vault-gpg"; };

  sops.secrets = {
    _aws_configure_profile_personal_sh = { inherit sopsFile; mode = "0500"; };
    _config_swm_config_yaml = { inherit sopsFile; path = "${yl_home}/.config/swm/config.yaml"; };
    _config_tiny_config_yml = { inherit sopsFile; path = "${yl_home}/.config/tiny/config.yml"; };
    _gist = { inherit sopsFile; path = "${yl_home}/.gist"; };
    _gist_vim = { inherit sopsFile; path = "${yl_home}/.gist-vim"; };
    _gitconfig_secrets = { inherit sopsFile; path = "${yl_home}/.gitconfig.secrets"; };
    _github_token = { inherit sopsFile; path = "${yl_home}/.github_token"; };
    _jrnl_config = { inherit sopsFile; path = "${yl_home}/.jrnl_config"; };
    _netrc = { inherit sopsFile; path = "${yl_home}/.netrc"; };
    _ssh_config_include_myself = { inherit sopsFile; path = "${yl_home}/.ssh/config_include_myself"; };
    _ssh_per-host_bitbucket_org_rsa = { inherit sopsFile; path = "${yl_home}/.ssh/per-host/bitbucket.org_rsa"; };
    _ssh_per-host_cronus_ed25519 = { inherit sopsFile; path = "${yl_home}/.ssh/per-host/cronus_ed25519"; };
    _ssh_per-host_gitlab_com_rsa = { inherit sopsFile; path = "${yl_home}/.ssh/per-host/gitlab.com_rsa"; };
    _ssh_per-host_hermes-gl-mt3000_bigeye-bushi_ts_net_ed25519 = { inherit sopsFile; path = "${yl_home}/.ssh/per-host/hermes-gl-mt3000.bigeye-bushi.ts.net_ed25519"; };
    _ssh_per-host_serial_nasreddine_com_rsa = { inherit sopsFile; path = "${yl_home}/.ssh/per-host/serial.nasreddine.com_rsa"; };
    _ssh_per-host_unifi_nasreddine_com_rsa = { inherit sopsFile; path = "${yl_home}/.ssh/per-host/unifi.nasreddine.com_rsa"; };
    _zsh_profiles_opensource_zsh = { inherit sopsFile; path = "${yl_home}/.zsh/profiles/opensource.zsh"; };
    _zsh_profiles_personal_zsh = { inherit sopsFile; path = "${yl_home}/.zsh/profiles/personal.zsh"; };
  };
}
