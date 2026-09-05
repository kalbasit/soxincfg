{
  config,
  lib,
  pkgs,
  hostType,
  ...
}:

let
  cfg = config.soxincfg.programs.steward;

  isDarwin = hostType == "nix-darwin";

  reserved = [
    "reliability"
    "capacity"
    "name"
  ];
  offending = lib.intersectLists reserved (lib.attrNames cfg.labels);

  # The agent takes every setting from the environment, so the unit needs no
  # arguments. STEWARD_TOKEN is deliberately absent: it comes from
  # credentialsFile at runtime, never from here, because everything below lands
  # in the world-readable nix store.
  env = {
    STEWARD_URL = cfg.url;
  }
  // lib.optionalAttrs (cfg.hostName != null) { STEWARD_HOST_NAME = cfg.hostName; }
  // lib.optionalAttrs (cfg.labels != { }) {
    STEWARD_LABELS = lib.concatStringsSep "," (lib.mapAttrsToList (k: v: "${k}=${v}") cfg.labels);
  }
  // lib.optionalAttrs (cfg.devices != [ ]) {
    STEWARD_DEVICES = lib.concatStringsSep "," cfg.devices;
  }
  // lib.optionalAttrs (cfg.reliability != null) { STEWARD_RELIABILITY = cfg.reliability; }
  // lib.optionalAttrs (cfg.capacity != null) { STEWARD_CAPACITY = toString cfg.capacity; }
  // lib.optionalAttrs (cfg.heartbeatInterval != null) {
    STEWARD_HEARTBEAT_INTERVAL = cfg.heartbeatInterval;
  };

  exe = lib.getExe cfg.package;
in
{
  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        assertions = [
          {
            assertion = offending == [ ];
            message =
              "soxincfg.programs.steward.labels sets ${lib.concatStringsSep ", " offending}, "
              + "which the control plane reserves. Each already has its own option, and a label "
              + "shadowing one is a second source for a value that has one answer.";
          }
        ];

        home.packages = [ cfg.package ];
      }

      # The agent is a supervised daemon rather than a timer. It holds one long
      # subscription and is expected to outlive the server going away: a control
      # plane that is down is a reconnect, not a reason for this machine to stop
      # being part of the fleet. So it restarts always, and the agent itself
      # exits only for a configuration it cannot use.
      (lib.mkIf (!isDarwin) {
        systemd.user.services.steward-agent = {
          Unit = {
            Description = "steward host agent: register this machine, report liveness, receive its work";
            # Registering before the network is up fails, and the agent would
            # rather reconnect than a unit flap at boot.
            After = [ "network-online.target" ];
            Wants = [ "network-online.target" ];
          };

          Service = {
            Type = "simple";
            ExecStart = exe;
            Environment = lib.mapAttrsToList (k: v: "${k}=${v}") env;
            EnvironmentFile = toString cfg.credentialsFile;
            Restart = "always";
            # Long enough that a genuinely broken configuration does not spin,
            # short enough that a machine waking from sleep rejoins promptly.
            RestartSec = "10s";
          };

          Install.WantedBy = [ "default.target" ];
        };
      })

      (lib.mkIf isDarwin {
        launchd.agents.steward-agent = {
          enable = true;
          config = {
            # launchd has no EnvironmentFile, so the credentials are sourced by
            # a shell instead. The token reaches the process through the
            # environment either way and is never written to the store.
            ProgramArguments = [
              "/bin/sh"
              "-c"
              ". ${toString cfg.credentialsFile}; exec ${exe}"
            ];
            EnvironmentVariables = env;
            RunAtLoad = true;
            KeepAlive = true;
          };
        };
      })
    ]
  );
}
