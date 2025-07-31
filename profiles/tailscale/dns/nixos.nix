{
  lib,
  pkgs,
  ...
}:

let
  k8s_overrides_path = "/etc/unbound/k8s-overrides.conf";
  nfs_overrides_path = "/mnt/shared_unbound_config/k8s-overrides.conf";
  main_unbound_config = "/etc/unbound/unbound.conf";
in
{
  # Allow traffic on port 53
  networking.firewall.allowedTCPPorts = [ 53 ];
  networking.firewall.allowedUDPPorts = [ 53 ];

  fileSystems = {
    "/mnt/shared_unbound_config" = {
      device = "192.168.52.10:/mnt/tank/proxmoxVE/pve_dns_unbound/unbound";
      fsType = "nfs";
    };
  };

  services = {
    # Enable keepalived
    keepalived = {
      enable = true;

      vrrpScripts = {
        check_unbound_process = {
          fall = 1;
          interval = 3;
          user = "root";
          weight = 20;

          script =
            let
              script = pkgs.writeShellScript "check-unbound-process.sh" ''
                set -eo pipefail
                ${lib.getExe' pkgs.procps "pidof"} unbound
              '';
            in
            builtins.toString script;
        };

        check_unbound_liveness = {
          fall = 1;
          interval = 3;
          user = "root";
          weight = 20;

          script =
            let
              script = pkgs.writeShellScript "check-unbound-liveness.sh" ''
                set -eo pipefail
                ${lib.getExe' pkgs.dnsutils "dig"} @127.0.0.1 -p 53 google.com +time=1 | ${lib.getExe pkgs.gnugrep} -q 'status: NOERROR'
              '';
            in
            builtins.toString script;
        };
      };
    };

    # Enable Tailscale so DNSMasq can call to Tailscale DNS directly.
    tailscale.enable = true;

    # Enable Unbound for DNS
    unbound = {
      enable = true;

      resolveLocalQueries = false;

      settings = {
        forward-zone = [
          {
            name = "bigeye-bushi.ts.net";
            forward-addr = "100.100.100.100";
          }

          {
            name = ".";
            forward-tls-upstream = true;

            # NextDNS DoQ servers with TLS authentication
            # The format is IP@port#<your-config-id>.dns.nextdns.io
            forward-addr = [
              "45.90.28.0#96893a.dns1.nextdns.io"
              "2a07:a8c0::#96893a.dns1.nextdns.io"
              "45.90.30.0#96893a.dns2.nextdns.io"
              "2a07:a8c1::#96893a.dns2.nextdns.io"
            ];
          }
        ];

        remote-control = {
          control-enable = true;
          control-interface = "127.0.0.1";
        };

        server = {
          # General and security options
          interface = [ "0.0.0.0" ];
          interface-automatic = true; # Allow replying from the VIP configured by KeepAlived
          access-control = "192.168.0.0/16 allow";
          do-ip4 = true;
          do-udp = true;
          do-tcp = true;

          # Caching options
          cache-min-ttl = 3600; # Serve stale data for an hour if upstream is down
          cache-max-ttl = 86400; # Cache records for up to a day
          prefetch = true; # Refreshes popular items before they expire
          prefetch-key = true; # Use DNSKEY to validate pre-fetched records

          # Include overrides from k8s cronjob.
          include = k8s_overrides_path;
        };
      };
    };
  };

  systemd.services = {
    # make sure the k8s-overrides is available before starting unbound
    unbound.after = [ "unbound-ensure-k8s-overrides-exists.service" ];
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
}
