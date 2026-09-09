{
  config,
  lib,
  mode,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkOption
    optionals
    types
    ;
in
{
  imports = optionals (mode == "nix-darwin") [ ./darwin.nix ];

  options.soxincfg.services.ssh-agent-mux = {
    enable = mkEnableOption "ssh-agent-mux service";

    logLevel = mkOption {
      type = types.enum [
        "error"
        "warn"
        "info"
        "debug"
      ];
      default = "info";
      description = ''
        Log level for the agent. The agent and its startup wrapper both write to
        ~/Library/Logs/ssh-agent-mux.log, appending so that a crash loop keeps
        its own history. Raise to "debug" to trace which upstream agent each
        signature request is routed to.
      '';
    };
  };
}
