{ config, ... }:
let
  yl_home = config.users.users.yl.home;
  owner = config.users.users.yl.name;
  sopsFile = ./home.sops.yaml;
in
{
  sops.secrets._aws_config = { inherit owner sopsFile; path = "${yl_home}/.aws/config"; };
  sops.secrets._aws_credentials = { inherit owner sopsFile; path = "${yl_home}/.aws/credentials"; };
}
