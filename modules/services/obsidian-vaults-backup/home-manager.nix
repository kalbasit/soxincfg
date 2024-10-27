{ config, lib, pkgs, ... }:

let
  inherit (lib)
    mkIf
    ;

  inherit (pkgs.hostPlatform)
    isDarwin
    ;

  cfg = config.soxincfg.services.obsidian-vaults-backup;
  sopsFile = ./secrets.sops.yaml;
  yl_home = config.home.homeDirectory;
in
{
  config = mkIf cfg.enable {
    sops.secrets = mkIf isDarwin {
      _ssh_per-host_github_com_obsidian_vaults_deploy_key_ed25519 = { inherit sopsFile; path = "${yl_home}/.ssh/per-host/github.com_obsidian_vaults_deploy_key_ed25519"; };
    };

    home.file = {
      ".ssh/per-host/github.com_obsidian_vaults_deploy_key_ed25519.pub".text = ''
        ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIILO1nghLFfzXbzQUCMevG7DXjFXTK8lSYq/Q7I12TGR GitHub Obsidian Vaults Deploy Key
      '';
    };

    systemd.user.timers."auto-backup-obsidian-vaults" = {
      Unit = {
        Description = "Automatically backup the Obsidian Vaults";
      };

      Timer = {
        OnBootSec = "5m";
        OnUnitInactiveSec = "5m";
        Unit = "auto-backup-obsidian-vaults.service";
      };

      Install = {
        WantedBy = [ "timers.target" ];
      };
    };

    systemd.user.services."auto-backup-obsidian-vaults" = {
      Unit = {
        Description = "Automatically backup the Obsidian Vaults";
      };

      Service = {
        PassEnvironment = "DISPLAY";
        ExecStart = pkgs.callPackage ./script.nix { inherit yl_home; };
      };
    };
  };
}
