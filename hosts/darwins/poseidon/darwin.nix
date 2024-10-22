{ config, lib, pkgs, inputs, soxincfg, ... }:

let
  inherit (lib)
    singleton
    ;
in
{
  imports = [
    soxincfg.nixosModules.profiles.myself
    soxincfg.nixosModules.profiles.workstation.darwin.local
  ];

  # load YL's home-manager configuration
  home-manager.users.yl = import ./home.nix { inherit soxincfg; };

  # Auto-Backup Obsidian Vaults and send them to GitHub
  launchd.user.agents.auto-backup-obsidian-vaults = {
    path = [ config.environment.systemPath ];

    serviceConfig.ProgramArguments =
      let
        script = pkgs.writeShellScript "auto-backup-obsidian-vaults" ''
          set -euo pipefail

          if ! test -d ~/SynologyDrive/Obsidian
          then
            exit 0
          fi

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

  system.stateVersion = 5;
}
