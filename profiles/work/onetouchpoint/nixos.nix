{ config, ... }:

let
  yl_home = config.users.users.yl.home;
  owner = config.users.users.yl.name;
  sopsFile = ./secrets.sops.yaml;
in
{
  sops.secrets = {
    _aws_configure_profile_onetouchpoint_sh = { inherit owner sopsFile; mode = "0500"; };
    _zsh_profiles_onetouchpoint_zsh = { inherit owner sopsFile; path = "${yl_home}/.zsh/profiles/onetouchpoint.zsh"; };
  };
}
