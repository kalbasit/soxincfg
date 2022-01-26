{ config, ... }:

let
  yl_home = config.users.users.yl.home;
  owner = config.users.users.yl.name;
  sopsFile = ./secrets.sops.yaml;
in
{
  sops.secrets._zsh_profiles_arklight_zsh = { inherit owner sopsFile; path = "${yl_home}/.zsh/profiles/arklight.zsh"; };
}
