{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    mkDefault
    mkIf
    mkMerge
    optionals
    singleton
    ;

  inherit (pkgs)
    onlykey
    onlykey-agent
    onlykey-cli
    writeShellScript
    ;

  inherit (pkgs.stdenv.hostPlatform) isLinux isDarwin;

  cfg = config.soxincfg.hardware.onlykey;

  gpg-agent-program = writeShellScript "run-onlykey-agent.sh" ''
    set -euo pipefail

    readonly stderrFile="$HOME/.gnupg/onlykey-agent.stderr.log"
    readonly stdoutFile="$HOME/.gnupg/onlykey-agent.stdout.log"

    # redirect stdout and stderr to log files, ignoring old logs (truncate mode).
    exec 1> "$stdoutFile"
    exec 2> "$stderrFile"

    exec ${onlykey-agent}/bin/onlykey-gpg-agent \
      --homedir ~/.gnupg \
      --skey-slot=${toString cfg.gnupg-support.signing-key-slot} \
      --dkey-slot=${toString cfg.gnupg-support.decryption-key-slot} \
      $*
  '';

  homePath = config.home.homeDirectory;
  sopsFile = ./secrets.sops.yaml;
in
{
  config = mkIf cfg.enable (mkMerge [
    { home.packages = [ onlykey-cli ] ++ optionals isLinux [ onlykey ]; }

    (mkIf isDarwin {
      sops.secrets._ssh_id_ed25519_sk_rk = {
        inherit sopsFile;
        path = "${homePath}/.ssh/id_ed25519_sk_rk";
      };
    })

    (mkIf cfg.ssh-support.enable {
      soxincfg.programs.ssh = {
        addKeysToAgent = mkDefault true;
        identityFiles = singleton "~/.ssh/id_ed25519_sk_rk";
      };

      home.file.".ssh/id_ed25519_sk_rk.pub".text = ''
        sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAILJKaAMg2OSpXi7+B1oIqzKz1lQiEZPo0Xv6ty35uwzzAAAABHNzaDo= wael.nasreddine+onlykey_0@gmail.com
      '';
    })

    (mkIf (cfg.ssh-support.enable && pkgs.stdenv.hostPlatform.isDarwin) {
      programs.zsh.initContent = ''
        if [[ "$(uname -s)" == "Darwin" ]]; then
          # Ensure XDG_RUNTIME_DIR is set on Darwin
          if [[ -z "$XDG_RUNTIME_DIR" ]]; then
            export XDG_RUNTIME_DIR="$(getconf DARWIN_USER_TEMP_DIR)"
            export XDG_RUNTIME_DIR="''${XDG_RUNTIME_DIR%/}"
          fi

          if [[ -S "$XDG_RUNTIME_DIR/ssh-agent-mux.sock" ]]; then
             export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent-mux.sock"
          else
             # Fallback: Initialize OnlyKey agent via keychain in the shell if service is not running
             # This also ensures we have a fallback if the user disables the service but keeps this module
             eval "$(${pkgs.keychain}/bin/keychain --eval id_ed25519_sk_rk -q)"
          fi

          # Link the current SSH_AUTH_SOCK to the standard location via .ssh/rc
          if [[ -e "$HOME/.ssh/rc" ]]; then
            /bin/sh "$HOME/.ssh/rc"
          fi
        fi
      '';
    })

    (mkIf cfg.gnupg-support.enable {
      home.file.".gnupg/run-agent.sh" = {
        source = gpg-agent-program;
        executable = true;
      };

      home.packages = singleton onlykey-agent;

      programs.gpg = {
        enable = true;

        settings = {
          inherit (cfg.gnupg-support) default-key;

          agent-program = toString gpg-agent-program;
          personal-digest-preferences = "SHA512";
        };

        publicKeys = [
          (mkIf (cfg.gnupg-support.decryption-key-public != null) {
            text = cfg.gnupg-support.decryption-key-public;
            trust = cfg.gnupg-support.decryption-key-trust;
          })

          (mkIf (cfg.gnupg-support.signing-key-public != null) {
            text = cfg.gnupg-support.signing-key-public;
            trust = cfg.gnupg-support.signing-key-trust;
          })
        ];
      };
    })
  ]);
}
