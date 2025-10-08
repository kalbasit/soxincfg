{
  pkgs,
  ...
}:

let
  k8s_overrides_path = "/etc/unbound/k8s-overrides.conf";
  nfs_overrides_path = "/mnt/shared_unbound_config/k8s-overrides.conf";
  main_unbound_config = "/etc/unbound/unbound.conf";

  # Path to the shared NFS mount
  shared_path = "/mnt/shared_unbound_config";
in
{
  fileSystems = {
    "${shared_path}" = {
      device = "192.168.52.10:/mnt/tank/proxmoxVE/pve_dns_unbound/unbound";
      fsType = "nfs";
    };
  };

  services = {
    # Enable keepalived
    keepalived = {
      vrrpInstances.dns_vip = {
        extraConfig =
          let
            # Start the merger timer immediately upon becoming master
            notifyMaster = pkgs.writeShellScript "notify-master.sh" ''
              set -e
              ${pkgs.systemd}/bin/systemctl start unbound-list-merger.timer
            '';

            # Script to run when this node becomes a BACKUP
            notifyBackup = pkgs.writeShellScript "notify-backup.sh" ''
              set -e
              ${pkgs.systemd}/bin/systemctl stop unbound-list-merger.timer
            '';
          in
          ''
            notify_master ${notifyMaster}
            notify_backup ${notifyBackup}
          '';
      };
    };

    # Include overrides from k8s cronjob.
    unbound.settings.server.include = k8s_overrides_path;
  };

  systemd = {
    services = {
      # make sure the k8s-overrides is available before starting unbound
      unbound-ensure-k8s-overrides-exists = {
        description = "Ensure ${k8s_overrides_path} exists";
        wantedBy = [ "multi-user.target" ];
        path = [ pkgs.coreutils ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart =
            let
              script = pkgs.writeShellScript "reload-unbound-overrides.sh" ''
                touch ${k8s_overrides_path}
              '';
            in
            script;
          RemainAfterExit = "yes";
        };
      };

      unbound-reload-k8s-overrides = {
        after = [
          "mnt-shared_unbound_config.mount"
          "unbound.service"
        ];
        description = "Reload ${k8s_overrides_path} from NFS if it changes";
        path = [
          pkgs.coreutils
          pkgs.gawk
          pkgs.unbound
        ];
        unitConfig = {
          ConditionPathExists = nfs_overrides_path;
        };
        serviceConfig = {
          Type = "oneshot";
          ExecStart =
            let
              script = pkgs.writeShellScript "reload-unbound-overrides.sh" ''
                set -euo pipefail

                # Define file paths from the Nix 'let' block above
                NFS_CONFIG_FILE="${nfs_overrides_path}"
                ACTIVE_CONFIG_FILE="${k8s_overrides_path}"
                BACKUP_CONFIG_FILE="$ACTIVE_CONFIG_FILE.bak"
                MAIN_UNBOUND_CONFIG="${main_unbound_config}"

                log() {
                    # Log to the systemd journal
                    echo "$(date --iso-8601=seconds): $1"
                }

                reload() {
                  # 1. Validate the new config file on the NFS share first.
                  #    We create a temporary wrapper to give unbound-checkconf context.
                  VALIDATION_WRAPPER_FILE=$(mktemp)
                  VALIDATION_DIRECTORY=$(mktemp -d)
                  cat <<EOF > $VALIDATION_WRAPPER_FILE
                  server:
                    chroot: ""
                    directory: "$VALIDATION_DIRECTORY"
                    include: "$NFS_CONFIG_FILE"
                EOF

                  log "Step 1: Validating new config on NFS..."
                  if ! unbound-checkconf "$VALIDATION_WRAPPER_FILE"; then
                    log "ERROR: New config on NFS is invalid. Aborting update." >&2
                    rm "$VALIDATION_WRAPPER_FILE"
                    rm -r "$VALIDATION_DIRECTORY"
                    return 1 # Go back to watching for the next change
                  fi
                  rm "$VALIDATION_WRAPPER_FILE"
                  rm -r "$VALIDATION_DIRECTORY"
                  log "New config syntax is valid."

                  # 2. Backup the current active config (if it exists)
                  log "Step 2: Backing up current active config..."
                  if [ -f "$ACTIVE_CONFIG_FILE" ]; then
                    cp -p "$ACTIVE_CONFIG_FILE" "$BACKUP_CONFIG_FILE"
                    log "Backup created at $BACKUP_CONFIG_FILE"
                  else
                    log "No active config found to back up. Creating empty backup."
                    touch "$BACKUP_CONFIG_FILE"
                  fi

                  # 3. Copy the new config from NFS to the active location
                  log "Step 3: Copying new config to $ACTIVE_CONFIG_FILE"
                  cp "$NFS_CONFIG_FILE" "$ACTIVE_CONFIG_FILE"

                  # 4. Validate the *entire* Unbound configuration with the new file in place
                  log "Step 4: Performing final validation of $MAIN_UNBOUND_CONFIG..."
                  if unbound-checkconf "$MAIN_UNBOUND_CONFIG"; then
                    # 5a. If valid, reload Unbound gracefully
                    log "Final validation successful. Reloading Unbound..."
                    unbound-control reload
                    log "Unbound reloaded successfully."
                  else
                    # 5b. If invalid, restore from backup and log a critical error
                    log "CRITICAL ERROR: New config breaks Unbound. Rolling back!" >&2
                    mv "$BACKUP_CONFIG_FILE" "$ACTIVE_CONFIG_FILE"
                    log "Rolled back to previous version. Please investigate the invalid config on the NFS share."
                  fi
                }

                # Read the hash of the current file
                CURRENT_HASH=$(sha256sum "$ACTIVE_CONFIG_FILE" | awk '{print $1}')

                # Read the hash of the file on NFS
                NEW_HASH=$(sha256sum "$NFS_CONFIG_FILE" | awk '{print $1}')

                # Reloading if the hash does not match
                if [ "$NEW_HASH" != "$CURRENT_HASH" ]; then
                  log "Detected change. Starting safe update process."
                  reload || "Failed to install the latest version"
                else
                  log "No change detected."
                fi
              '';
            in
            script;
        };
      };
    };

    timers = {
      unbound-reload-k8s-overrides = {
        timerConfig = {
          OnBootSec = "5min";
          OnUnitActiveSec = "1m";
          Persistent = true;
        };
        wantedBy = [ "timers.target" ];
      };
    };
  };
}
