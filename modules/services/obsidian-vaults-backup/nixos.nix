{ config, lib, ... }:

let
  inherit (lib)
    mkIf
    ;

  cfg = config.soxincfg.services.obsidian-vaults-backup;
  owner = config.users.users.yl.name;
  sopsFile = ./secrets.sops.yaml;
  yl_home = config.users.users.yl.home;
in
{
  config = mkIf cfg.enable {
    sops.secrets = {
      _ssh_per-host_github_com_obsidian_vaults_deploy_key_ed25519 = { inherit owner sopsFile; path = "${yl_home}/.ssh/per-host/github.com_obsidian_vaults_deploy_key_ed25519"; };
    };
  };
}
