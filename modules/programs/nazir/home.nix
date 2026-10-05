{
  config,
  lib,
  pkgs,
  hostType,
  ...
}:

let
  cfg = config.soxincfg.programs.nazir;

  isDarwin = hostType == "nix-darwin";

  reserved = [
    "reliability"
    "capacity"
    "name"
  ];
  offending = lib.intersectLists reserved (lib.attrNames cfg.labels);

  # The agent takes every setting from the environment, so the unit needs no
  # arguments. NAZIR_TOKEN is deliberately absent: it comes from
  # credentialsFile at runtime, never from here, because everything below lands
  # in the world-readable nix store.
  env = {
    NAZIR_URL = cfg.url;
  }
  // lib.optionalAttrs (cfg.hostName != null) { NAZIR_HOST_NAME = cfg.hostName; }
  // lib.optionalAttrs (cfg.labels != { }) {
    NAZIR_LABELS = lib.concatStringsSep "," (lib.mapAttrsToList (k: v: "${k}=${v}") cfg.labels);
  }
  // lib.optionalAttrs (cfg.devices != [ ]) {
    NAZIR_DEVICES = lib.concatStringsSep "," cfg.devices;
  }
  // lib.optionalAttrs (cfg.reliability != null) { NAZIR_RELIABILITY = cfg.reliability; }
  // lib.optionalAttrs (cfg.capacity != null) { NAZIR_CAPACITY = toString cfg.capacity; }
  // lib.optionalAttrs (cfg.heartbeatInterval != null) {
    NAZIR_HEARTBEAT_INTERVAL = cfg.heartbeatInterval;
  };

  # What both units start instead of the agent itself: a compatibility shim
  # for credentials files written before the steward -> nazir rename.
  #
  # The per-host secrets hold `STEWARD_TOKEN=...` (and possibly other
  # STEWARD_* keys), and the agent now reads only NAZIR_*. Rather than re-key
  # every secret in the same change, each STEWARD_<x> found in the environment
  # is exported as NAZIR_<x> when NAZIR_<x> is unset, then dropped, so the
  # agent and the workers it starts see one spelling. A NAZIR_<x> already set
  # -- by the unit or by a re-keyed file -- always wins.
  #
  # Given a file, it sources it first (launchd has no EnvironmentFile, see
  # below); given none, it works on what systemd's EnvironmentFile= already
  # put in the environment. Delete the mapping once no credentials file holds
  # a STEWARD_ key.
  launcher = pkgs.writeShellApplication {
    name = "nazir-agent-launch";
    text = ''
      if [[ $# -gt 0 ]]; then
        # `set -a` is load-bearing: without allexport, `. file` sets shell
        # variables that do not survive into the exec'd agent's environment.
        set -a
        # shellcheck disable=SC1090
        . "$1"
        set +a
      fi

      # "''${!STEWARD_@}" (the names of every variable with that prefix), not
      # `compgen -A export`: compgen belongs to programmable completion, which
      # nixpkgs' non-interactive bash -- the one writeShellApplication runs --
      # is built without. There it is "command not found", the mapping never
      # runs, and the agent exits for want of a token. Each name here came from
      # the environment or the sourced file, so is exported either way.
      for old in "''${!STEWARD_@}"; do
        new="NAZIR_''${old#STEWARD_}"
        if [[ -z "''${!new+x}" ]]; then
          export "$new=''${!old}"
        fi
        unset "$old"
      done

      exec ${lib.getExe cfg.package}
    '';
  };

  exe = lib.getExe launcher;
in
{
  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        assertions = [
          {
            # The agent starts work by asking maktab to open a pane, so a
            # host running it needs maktab *configured*, not merely present.
            # The binary alone is not enough: soxincfg.programs.maktab writes
            # config.toml and session-tmux.toml, and without them maktab does
            # not know which session plugin to drive.
            #
            # An assertion rather than enabling maktab from here. Turning on
            # another module as a side effect would also bring its shell
            # aliases, pet snippets and tmux binding, which is a lot to inherit
            # from switching on a work agent -- and it would hide the
            # dependency from whoever reads the host's configuration. Failing
            # the build says it once, at the moment someone can act on it.
            assertion = config.soxincfg.programs.maktab.enable;
            message =
              "soxincfg.programs.nazir.enable requires soxincfg.programs.maktab.enable: "
              + "the agent starts work through maktab, and a host with the agent but no maktab "
              + "registers, heartbeats, accepts assignments and then fails every one of them.";
          }
          {
            assertion = offending == [ ];
            message =
              "soxincfg.programs.nazir.labels sets ${lib.concatStringsSep ", " offending}, "
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
        systemd.user.services.nazir-agent = {
          Unit = {
            Description = "Nazir host agent: register this machine, report liveness, receive its work";
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
        launchd.agents.nazir-agent = {
          enable = true;
          config = {
            # launchd has no EnvironmentFile, so the launcher sources the
            # credentials itself. The token reaches the process through the
            # environment either way and is never written to the store.
            #
            # The sourcing needs `set -a`, which the launcher carries: without
            # it `. file` sets shell variables that do not survive the exec, so
            # the token is read and immediately discarded. The agent then exits
            # for a configuration it cannot use -- correctly, and in about 39ms
            # -- and launchd restarts it forever.
            #
            # systemd's EnvironmentFile= parses KEY=value into the environment
            # directly, which is why the Linux path never had this bug and why
            # emulating it here needs the export to be explicit.
            ProgramArguments = [
              exe
              (toString cfg.credentialsFile)
            ];
            # launchd hands a job a minimal PATH -- /usr/bin:/bin and the two
            # sbin directories -- and nothing else. The nix profile is absent,
            # so the workspace manager (swm then, maktab now) was unreachable
            # to the agent while being immediately findable in a terminal,
            # which is what made this look like it not being installed at all.
            #
            # systemd's user manager inherits the profile PATH, which is why
            # the Linux branch above never needed this. It is the same
            # asymmetry as the EnvironmentFile note above: something systemd
            # provides silently that launchd does not.
            #
            # Broad rather than just maktab's own bin, because this PATH also
            # reaches the workers. The agent starts the workspace, so the
            # multiplexer server it spawns inherits this environment, and every
            # pane opened in it inherits that in turn -- a PATH narrow enough
            # for maktab alone would leave the worker unfindable in the pane it
            # was started in.
            EnvironmentVariables = env // {
              # launchd hands a job no locale either, so the agent and
              # everything it spawns run in the C charset. `swm pane list`
              # came back empty there -- tmux reported the panes, swm dropped
              # them -- and nazir reads an empty list as "the pane I just
              # opened is gone". The only guess it makes for that is the
              # supervisor having failed to exec, so every darwin assignment
              # died naming a binary that was on PATH the whole time.
              #
              # Set here for the same reason PATH is, and it has to reach the
              # same distance: the agent spawns the multiplexer server, and
              # every pane opened in it inherits this in turn. systemd's user
              # manager inherits the user's locale, which is why the Linux
              # branch above never needed it -- the third instance of that same
              # asymmetry, after EnvironmentFile and PATH.
              LANG = "en_US.UTF-8";

              PATH = lib.concatStringsSep ":" [
                "${config.home.profileDirectory}/bin"
                "/run/current-system/sw/bin"
                "/nix/var/nix/profiles/default/bin"
                "/usr/bin"
                "/bin"
                "/usr/sbin"
                "/sbin"
              ];
            };
            RunAtLoad = true;
            KeepAlive = true;

            # Without these launchd discards stdout and stderr, and the agent's
            # one-line explanation of its own failure goes to /dev/null. That
            # is what turned this bug from "says exactly what is wrong" into
            # "appears never to have started", and it is why it survived a day
            # of restarts unnoticed.
            StandardOutPath = "${config.home.homeDirectory}/Library/Logs/nazir-agent/stdout";
            StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/nazir-agent/stderr";
          };
        };

        # launchd will not create the log directory, and a job whose
        # StandardErrorPath cannot be opened loses the diagnostics this was
        # added for.
        home.file."Library/Logs/nazir-agent/.keep".text = "";
      })
    ]
  );
}
