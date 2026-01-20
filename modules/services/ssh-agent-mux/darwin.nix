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

    # Initialize OnlyKey agent via keychain if available
    mkdir -p "$HOME/.ssh/agent"
    eval "$(${pkgs.keychain}/bin/keychain --ssh-agent-socket "$HOME/.ssh/agent/keychain.socket" --eval id_ed25519_sk_rk -q)"
    ONLYKEY_AUTH_SOCK="$SSH_AUTH_SOCK"

    # Secretive agent socket location
    SECRETIVE_AUTH_SOCK="$HOME/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh"

    ARGS=(
      "-l"
      "$XDG_RUNTIME_DIR/ssh-agent-mux.sock"
      "$SECRETIVE_AUTH_SOCK"
      "$ONLYKEY_AUTH_SOCK"
    )

    # exec ssh-agent-mux
    # Assuming ssh-agent-mux is installed in system packages or we use the specific package if available.
    # Since it was added via patch, we might need to access it from pkgs.
    exec ${pkgs.ssh-agent-mux}/bin/ssh-agent-mux "''${ARGS[@]}"
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
        # StandardOutPath = "/tmp/ssh-agent-mux.log"; # For debugging
        # StandardErrorPath = "/tmp/ssh-agent-mux.err"; # For debugging
      };
    };
  };
}
