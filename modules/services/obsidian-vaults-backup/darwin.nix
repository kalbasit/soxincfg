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
    launchd.user.agents.auto-backup-obsidian-vaults = {
      path = [ config.environment.systemPath ];

      serviceConfig.ProgramArguments = pkgs.callPackage ./script.nix { inherit yl_home; };

      serviceConfig.KeepAlive = true;
      serviceConfig.ProcessType = "Interactive";
    };
  };
}
