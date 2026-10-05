{
  lib,
  mode,
  pkgs,
  ...
}:

{
  imports = lib.optional (mode == "home-manager") ./home.nix;

  options.soxincfg.programs.nazir = {
    enable = lib.mkEnableOption "the Nazir host agent";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.nazir-agent;
      defaultText = lib.literalExpression "pkgs.nazir-agent";
      description = ''
        The package providing `nazir-agent`.

        Only the agent, never the server: a machine that runs work has no use
        for the control plane it talks to. The agent supervises its workers
        itself, as majlis harness sessions; there is no separate supervisor.
      '';
    };

    workerPackage = lib.mkOption {
      type = lib.types.package;
      default = pkgs.claude-code.override {
        manifest = lib.importJSON ./claude-code-manifest.json;
      };
      defaultText = lib.literalExpression "pkgs.claude-code pinned by ./claude-code-manifest.json (2.1.287)";
      description = ''
        The Claude Code the agent starts in a pane for each item (NAZIR_WORKER,
        by store path).

        Pinned, not whatever `claude` is on the agent's PATH: majlis trusts a
        Claude Code version only after a conformance run, and an unverified one
        holds every message until the session is idle. 2.1.287 is the verified
        one. The manifest is Anthropic's release manifest for that version
        (its darwin-arm64 checksum matched the binary saturn runs). Bump it
        with the version majlis' capability record cites, not before.
      '';
    };

    workerArgs = lib.mkOption {
      type = lib.types.listOf (lib.types.strMatching "[^[:space:]]+");
      default = [ ];
      example = [
        "--permission-mode"
        "acceptEdits"
      ];
      description = ''
        Arguments added to every worker's command line (NAZIR_WORKER_ARGS),
        such as a permission mode. The agent splits the variable on
        whitespace, so no argument may contain any. Empty adds nothing: the
        worker runs with the account's own Claude Code settings.
      '';
    };

    reportNudge = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "30m";
      description = ''
        How long a running item's worker may sit idle without reporting
        before the agent reminds it once (NAZIR_REPORT_NUDGE), as a Go
        duration; "0" disables the reminder. Null leaves the agent's default
        of 15m.
      '';
    };

    url = lib.mkOption {
      type = lib.types.str;
      example = "https://nazir.nasreddine.com";
      description = ''
        The control plane's base URL.

        Has no default. A wrong one is a host that looks configured and
        registers with nothing, which is worse than a host that refuses to
        start.
      '';
    };

    credentialsFile = lib.mkOption {
      type = lib.types.path;
      example = lib.literalExpression ''config.sops.secrets."nazir/env".path'';
      description = ''
        A file of `KEY=value` lines holding at least `NAZIR_TOKEN`, the
        credential this host authenticates with.

        Point this at a sops-nix secret. It is read at runtime and never copied
        into the nix store.

        Files written before the rename hold `STEWARD_TOKEN` (and possibly
        other `STEWARD_*` keys) instead, and are still accepted: the unit
        exports each `STEWARD_<x>` as `NAZIR_<x>` when `NAZIR_<x>` is unset.
        That is a bridge until the secrets are re-keyed, not a second spelling
        to keep.

        Required, and deliberately not an option that can hold the token
        directly. The agent itself refuses to read its token from a flag,
        because a credential on a command line is visible in every process
        listing on the machine — and a token written into a unit file would be
        world-readable in the store, which is the same mistake one layer up.
      '';
    };

    hostName = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = ''
        The name this host registers under. Null lets the agent use the
        machine's hostname.

        Set it when the machine's hostname is not stable — the name is how work
        already placed here is found again after a restart, so a name that
        changes strands that work on a host that no longer exists.
      '';
    };

    labels = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      example = lib.literalExpression ''{ os = "linux"; location = "home"; }'';
      description = ''
        Labels describing this host, which the scheduler matches work against.

        `reliability`, `capacity` and `name` are refused: each has its own
        option, and a label shadowing one would be a second source for a value
        that already has an answer.
      '';
    };

    devices = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = lib.literalExpression ''[ "android" ]'';
      description = ''
        Resources physically attached to this machine, which work can require.

        A device is a hard constraint rather than a preference: work needing
        one will not be placed on a host without it, however idle that host is.
      '';
    };

    reliability = lib.mkOption {
      type = lib.types.nullOr (
        lib.types.enum [
          "always_on"
          "sleeps"
          "intermittent"
        ]
      );
      default = null;
      description = ''
        Whether this machine can be relied on to stay awake.

        `always_on` never suspends. `sleeps` suspends predictably, which is a
        laptop that closes. `intermittent` is reachable unpredictably, which is
        a different thing from sleeping and is why the two are not one value.

        Saying so is what stops long work being placed where it will vanish
        mid-flight. Null leaves the agent's own default.

        Underscores, not hyphens: these are the control plane's own values and
        it refuses anything else, so a hyphen here is a host that fails to
        register rather than a host with a cosmetic typo.
      '';
    };

    capacity = lib.mkOption {
      type = lib.types.nullOr lib.types.ints.positive;
      default = null;
      description = ''
        How many work items may run here at once. Null leaves the agent's
        default of one.
      '';
    };

    heartbeatInterval = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "30s";
      description = ''
        How often the agent reports liveness. Null leaves the agent's default.

        A Go duration string, passed through unchanged — this is not a systemd
        duration and is not converted.
      '';
    };
  };
}
