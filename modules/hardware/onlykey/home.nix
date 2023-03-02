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

  gpg-agent-program = writeShellScript "run-onlykey-agent.sh" ''
    set -euo pipefail

    exec ${onlykey-agent}/bin/onlykey-gpg-agent \
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

      home.file.".ssh/id_ed25519_sk_rk.pub".text = ''
        sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAILJKaAMg2OSpXi7+B1oIqzKz1lQiEZPo0Xv6ty35uwzzAAAABHNzaDo= wael.nasreddine+onlykey_0@gmail.com
      '';
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
