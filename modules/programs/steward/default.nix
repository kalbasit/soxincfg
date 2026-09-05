{
  lib,
  mode,
  pkgs,
  ...
}:

{
  imports = lib.optional (mode == "home-manager") ./home.nix;

  options.soxincfg.programs.steward = {
    enable = lib.mkEnableOption "the steward host agent";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.steward-agent;
      defaultText = lib.literalExpression "pkgs.steward-agent";
      description = ''
        The package providing `steward-agent`.

        Only the agent, never the server: a machine that runs work has no use
        for the control plane it talks to.
      '';
    };

    url = lib.mkOption {
      type = lib.types.str;
      example = "https://steward.nasreddine.com";
      description = ''
        The control plane's base URL.

        Has no default. A wrong one is a host that looks configured and
        registers with nothing, which is worse than a host that refuses to
        start.
      '';
    };

    credentialsFile = lib.mkOption {
      type = lib.types.path;
      example = lib.literalExpression ''config.sops.secrets."steward/env".path'';
      description = ''
        A file of `KEY=value` lines holding at least `STEWARD_TOKEN`, the
        credential this host authenticates with.

        Point this at a sops-nix secret. It is read at runtime and never copied
        into the nix store.

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
          "always-on"
          "intermittent"
        ]
      );
      default = null;
      description = ''
        Whether this machine can be relied on to stay awake.

        A laptop that sleeps is `intermittent`, and saying so is what stops
        long work being placed on it. Null leaves the agent's own default.
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
