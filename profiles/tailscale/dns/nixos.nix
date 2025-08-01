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
      # EXPORTER: Each server exports its own list to the shared mount.
      unbound-cache-exporter = {
        after = [
          "mnt-shared_unbound_config.mount"
          "unbound.service"
        ];
        requires = [
          "mnt-shared_unbound_config.mount"
          "unbound.service"
        ];
        description = "Export this server's active domains to the shared mount";
        path = [
          pkgs.inetutils
          pkgs.soxincfg.unbound-cache-exporter
        ];
        serviceConfig = {
          Type = "oneshot";
          User = "root";
        };
        script =
          let
            script = pkgs.writeShellScript "unbound-cache-exporter.sh" ''
              set -euo pipefail
              # The script now calls the Python script with a unique output file path
              # based on the server's hostname. e.g., popular-domains-pve-dns0.txt
              unbound-cache-exporter "${shared_path}/popular-domains-$(hostname).txt"
            '';
          in
          builtins.toString script;
      };

      # MERGER: The keepalived MASTER server merges all lists into a master list.
      unbound-list-merger = {
        description = "Merge all individual domain lists into a master list (only runs on keepalived MASTER)";

        path = [
          pkgs.coreutils
          pkgs.findutils
          pkgs.gnugrep
          pkgs.iproute2
        ];

        serviceConfig.Type = "oneshot";

        script =
          let
            script = pkgs.writeShellScript "unbound-list-merger.sh" ''
              set -euo pipefail

              log() {
                  echo "unbound-list-merger: $1"
              }

              log "This node is the keepalived MASTER. Merging domain lists..."
              # Use find to handle the case where no files exist, preventing an error.
              # Then, concatenate all lists, sort them, remove duplicates, and write to the master file atomically.
              find "${shared_path}" -name 'popular-domains-*.txt' -print0 | xargs -0 cat | grep -v '^#' | sort -u > "${shared_path}/popular-domains-master.tmp"
              mv "${shared_path}/popular-domains-master.tmp" "${shared_path}/popular-domains-master.txt"
              log "Master domain list updated."
            '';
          in
          builtins.toString script;
      };

      # PRIMER: All servers prime their cache from the shared master list.
      unbound = {
        after = [
          "mnt-shared_unbound_config.mount"
          "unbound-ensure-k8s-overrides-exists.service"
        ];
        serviceConfig = {
          # This command runs AFTER the main Unbound process has started on ALL servers
          ExecStartPost =
            let
              script = pkgs.writeShellScript "prime-dns.sh" ''
                set -euo pipefail

                MASTER_LIST_FILE="${shared_path}/popular-domains-master.txt"

                log() {
                    echo "unbound-cache-primer: $1"
                }

                if [ -f "$MASTER_LIST_FILE" ]; then
                  log "Priming Unbound cache from shared master list..."
                  # Read the file line by line
                  while IFS= read -r domain || [[ -n "$domain" ]]; do
                    # Skip empty lines or comments
                    if [[ -z "$domain" || "$domain" == \#* ]]; then
                        continue
                    fi
                    # Query the local server for each domain to populate the cache
                    ${pkgs.dnsutils}/bin/dig @127.0.0.1 "$domain" > /dev/null 2>&1 || true
                  done < "$MASTER_LIST_FILE"
                  log "Cache priming complete."
                else
                  log "Master domain list not found, skipping cache priming."
                fi
              '';
            in
            [ script ];
        };
      };

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

      unbound-auto-reload-k8s-overrides = {
        after = [
          "mnt-shared_unbound_config.mount"
          "unbound.service"
        ];
        description = "Reload ${k8s_overrides_path} from NFS if it changes";
        wantedBy = [ "multi-user.target" ];
        path = [
          pkgs.coreutils
          pkgs.gawk
          pkgs.unbound
        ];
        unitConfig = {
          ConditionPathExists = nfs_overrides_path;
        };
        serviceConfig = {
          Type = "simple";
          ExecStart =
            let
              script = pkgs.writeShellScript "reload-unbound-overrides.sh" ''
                set -euo pipefail

                # Define file paths from the Nix 'let' block above
                NFS_CONFIG_FILE="${nfs_overrides_path}"
                ACTIVE_CONFIG_FILE="${k8s_overrides_path}"
                BACKUP_CONFIG_FILE="$ACTIVE_CONFIG_FILE.bak"
                MAIN_UNBOUND_CONFIG="${main_unbound_config}"

                # Initialize with an empty hash
                CURRENT_HASH=""

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

                # --- Main Loop ---
                log "Watching for changes in $NFS_CONFIG_FILE..."
                while true; do
                  NEW_HASH=$(sha256sum "$NFS_CONFIG_FILE" | awk '{print $1}')

                  if [ "$NEW_HASH" != "$CURRENT_HASH" ]; then
                    log "Detected change. Starting safe update process."
                    if ! reload; then
                      log "The latest version failed validation."
                    else
                      CURRENT_HASH="$NEW_HASH"
                    fi
                    reload || "Failed to install the latest version"
                  else
                    log "No change detected."
                  fi

                  # Wait for 60 seconds before checking again
                  sleep 60
                done
              '';
            in
            script;
          RemainAfterExit = "yes";
        };
      };
    };

    timers = {
      # EXPORTER: Each server exports its own list to the shared mount.
      unbound-cache-exporter = {
        timerConfig = {
          OnBootSec = "5min";
          OnUnitActiveSec = "1h";
        };
        wantedBy = [ "timers.target" ];
      };

      # MERGER: The keepalived MASTER server merges all lists into a master list.
      unbound-list-merger = {
        timerConfig = {
          OnBootSec = "10min";
          OnUnitActiveSec = "2h";
        };
      };
    };
  };
}
