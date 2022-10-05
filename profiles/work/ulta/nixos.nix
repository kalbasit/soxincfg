{ config, ... }:

let
  yl_home = config.users.users.yl.home;
  owner = config.users.users.yl.name;
  sopsFile = ./secrets.sops.yaml;
in
{
  sops.secrets={
  _aws_configure_profile_ulta_sh = { inherit owner sopsFile; mode = "0500"; };
  _ssh_config_include_work_ulta = { inherit owner sopsFile; path = "${yl_home}/.ssh/config_include_work_ulta"; };
  _ssh_per-host_linnaeus_io_rsa = { inherit owner sopsFile; path = "${yl_home}/.ssh/per-host/linnaeus.io_rsa"; };
  _zsh_profiles_ulta_zsh = { inherit owner sopsFile; path = "${yl_home}/.zsh/profiles/ulta.zsh"; };
  };
}
