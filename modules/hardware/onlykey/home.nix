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

  inherit (pkgs.hostPlatform) isLinux isDarwin;

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

  yl_home = config.home.homeDirectory;
  sopsFile = ./secrets.sops.yaml;
in
{
  config = mkIf cfg.enable (mkMerge [
    { home.packages = [ onlykey-cli ] ++ optionals isLinux [ onlykey ]; }

    (mkIf isDarwin {
      sops.secrets._ssh_id_ed25519_sk_rk = {
        inherit sopsFile;
        path = "${yl_home}/.ssh/id_ed25519_sk_rk";
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
      programs.zsh.initExtra = ''
        if [[ -e "$HOME/.ssh/rc" ]]; then
          (
            eval "$(${pkgs.keychain}/bin/keychain --eval --agents ssh id_ed25519_sk_rk -q)"

            /bin/sh "$HOME/.ssh/rc"
          )
        else
          eval "$(${pkgs.keychain}/bin/keychain --eval --agents ssh id_ed25519_sk_rk -q)"
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
