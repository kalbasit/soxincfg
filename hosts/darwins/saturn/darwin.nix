{ config, lib, pkgs, inputs, soxincfg, ... }:

let
  inherit (lib)
    mkForce
    singleton
    ;
in
{
  imports = [
    soxincfg.nixosModules.profiles.myself
    soxincfg.nixosModules.profiles.workstation.darwin.local
  ]
  ++ (soxincfg.nixosModules.profiles.work.imports { hostName = "saturn"; });

  # load YL's home-manager configuration
  home-manager.users.yl = import ./home.nix { inherit soxincfg; };

  # Auto-Backup Obsidian Vaults and send them to GitHub
  launchd.user.agents.auto-backup-obsidian-vaults = {
    path = [ config.environment.systemPath ];

    serviceConfig.ProgramArguments =
      let
        script = pkgs.writeShellScript "auto-backup-obsidian-vaults" ''
          set -euo pipefail

          cd ~/SynologyDrive/Obsidian

          while true
          do
            git add -A .
            git commit --no-gpg-sign -m 'Auto-Backup from user agent auto-backup-obsidian-vaults'
            git push origin main

            sleep 5m
          done
        '';
      in
      singleton (builtins.toString script);

    serviceConfig.KeepAlive = true;
    serviceConfig.ProcessType = "Interactive";
  };

  # Keep the name given by the org
  networking.hostName = mkForce "Canary-WP943K0HYC";

  system.stateVersion = 5;
}
