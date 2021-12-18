{ config, lib, pkgs, ... }:

let
  inherit (lib)
    mkDefault
    mkIf
    mkMerge
    singleton
    ;

  inherit (pkgs)
    onlykey
    onlykey-agent
    onlykey-cli
    writeShellScript
    ;

  cfg = config.soxincfg.hardware.onlykey;

  # TODO: Create a systemd user unit for this GnuPG agent.
  # https://docs.crp.to/onlykey-agent.html#how-do-i-start-the-agent-as-a-systemd-unit
  gpg-agent-program = writeShellScript "run-onlykey-agent.sh" ''
    set -euo pipefail

    exec ${onlykey-agent}/bin/onlykey-gpg-agent \
      -vv \
      --skey-slot=${toString cfg.gnupg-support.signing-key-slot} \
      --dkey-slot=${toString cfg.gnupg-support.decryption-key-slot} \
      $*
  '';
in
{
  config = mkIf cfg.enable (mkMerge [
    { home.packages = [ onlykey onlykey-agent onlykey-cli ]; }

    (mkIf cfg.ssh-support.enable {
      soxincfg.programs.ssh = {
        identitiesOnly = mkDefault true;
        identityFiles = singleton "~/.ssh/id_ed25519_sk_rk";
      };
    })

    (mkIf cfg.gnupg-support.enable {
      home.file.".gnupg/run-agent.sh" = {
        source = gpg-agent-program;
        executable = true;
      };

      programs.gpg = {
        enable = true;

        settings = {
          agent-program = toString gpg-agent-program;
          personal-digest-preferences = "SHA512";
          default-key = cfg.gnupg-support.default-key;
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
