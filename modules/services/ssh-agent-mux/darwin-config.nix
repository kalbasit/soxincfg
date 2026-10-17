{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkIf;

  cfg = config.soxincfg.services.ssh-agent-mux;

  wrapper = pkgs.writeShellScript "ssh-agent-mux-start" ''
    set -euo pipefail

    # Ensure XDG_RUNTIME_DIR is set
    if [[ -z "''${XDG_RUNTIME_DIR:-}" ]]; then
       export XDG_RUNTIME_DIR="$(getconf DARWIN_USER_TEMP_DIR)"
       export XDG_RUNTIME_DIR="''${XDG_RUNTIME_DIR%/}"
    fi

    # Take over stdout and stderr before anything can fail, so this wrapper's own
    # errors land in the log rather than being swallowed by launchd. ssh-agent-mux
    # logs to stdout when given no --log-file, so this one redirect covers both
    # and leaves a single writer on the file.
    mkdir -p "$HOME/Library/Logs"
    exec >> "$HOME/Library/Logs/ssh-agent-mux.log" 2>&1

    echo "--- $(/bin/date +%FT%T%z): starting ssh-agent-mux ---"

    # Upstream agent sockets, both at fixed paths their owning agent creates:
    # Secretive's container socket, and the one keychain is pointed at below.
    # ssh-agent-mux re-checks these on every identity refresh and skips whichever
    # are missing, so naming a socket that does not exist yet is safe and lets
    # that upstream join later without restarting the mux.
    SECRETIVE_AUTH_SOCK="$HOME/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh"
    ONLYKEY_AUTH_SOCK="$HOME/.ssh/agent/keychain.socket"

    # Bring up the OnlyKey agent. This must not be fatal: with the OnlyKey
    # detached ssh-add fails, and exiting here would crash-loop the service under
    # KeepAlive and leave every shell with no agent at all.
    mkdir -p "$HOME/.ssh/agent"
    if keychainEnv="$(${pkgs.keychain}/bin/keychain --ssh-agent-socket "$ONLYKEY_AUTH_SOCK" --eval id_ed25519_sk_rk -q)"; then
      eval "$keychainEnv"
    else
      echo "warning: keychain could not load id_ed25519_sk_rk; starting without the OnlyKey upstream"
    fi

    exec ${pkgs.ssh-agent-mux}/bin/ssh-agent-mux \
      --log-level ${cfg.logLevel} \
      -l "$XDG_RUNTIME_DIR/ssh-agent-mux.sock" \
      "$SECRETIVE_AUTH_SOCK" \
      "$ONLYKEY_AUTH_SOCK"
  '';
in
{
  config = mkIf cfg.enable {
    # Install the package
    environment.systemPackages = [ pkgs.ssh-agent-mux ];

    launchd.user.agents.ssh-agent-mux = {
      serviceConfig = {
        Label = "net.ross-williams.ssh-agent-mux";
        ProgramArguments = [ "${wrapper}" ];
        KeepAlive = {
          Crashed = true;
          SuccessfulExit = false;
        };
        RunAtLoad = true;
      };
    };
  };
}
