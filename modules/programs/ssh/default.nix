{ mode, config, pkgs, lib, ... }:

with lib;
let
  cfg = config.soxincfg.programs.ssh;

  yesOrNo = v: if v then "yes" else "no";
in
{
  # Configuration comes from
  # https://infosec.mozilla.org/guidelines/openssh

  options = {
    soxincfg.programs.ssh = {
      enable = mkEnableOption "enable SSH client";

      hashKnownHosts = mkEnableOption "hash known hosts";

      hostKeyAlgorithms = mkOption {
        type = with types; listOf str;
        default = [
          "ssh-ed25519-cert-v01@openssh.com"
          "ssh-rsa-cert-v01@openssh.com"
          "ssh-ed25519"
          "ssh-rsa"
          "ecdsa-sha2-nistp521-cert-v01@openssh.com"
          "ecdsa-sha2-nistp384-cert-v01@openssh.com"
          "ecdsa-sha2-nistp256-cert-v01@openssh.com"
          "ecdsa-sha2-nistp521"
          "ecdsa-sha2-nistp384"
          "ecdsa-sha2-nistp256"
        ];
        description = ''
          Specifies the host key algorithms that the client wants to use in
          order of preference.
        '';
      };

      kexAlgorithms = mkOption {
        type = with types; listOf str;
        default = [
          "curve25519-sha256@libssh.org"
          "ecdh-sha2-nistp521"
          "ecdh-sha2-nistp384"
          "ecdh-sha2-nistp256"
          "diffie-hellman-group-exchange-sha256"
        ];
        description = ''
          Specifies the available KEX (Key Exchange) algorithms.
        '';
      };

      macs = mkOption {
        type = with types; listOf str;
        default = [
          "hmac-sha2-512-etm@openssh.com"
          "hmac-sha2-256-etm@openssh.com"
          "umac-128-etm@openssh.com"
          "hmac-sha2-512"
          "hmac-sha2-256"
          "umac-128@openssh.com"
        ];
        description = ''
          Specifies the MAC (message authentication code) algorithms in order
          of preference. The MAC algorithm is used for data integrity
          protection.
        '';
      };

      ciphers = mkOption {
        type = with types; listOf str;
        default = [
          "chacha20-poly1305@openssh.com"
          "aes256-gcm@openssh.com"
          "aes128-gcm@openssh.com"
          "aes256-ctr"
          "aes192-ctr"
          "aes128-ctr"
        ];
        description = ''
          Specifies the ciphers allowed and their order of preference.
        '';
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      programs.ssh = {
        extraConfig = ''
          PubkeyAuthentication yes
          # Ensure KnownHosts are unreadable if leaked - it is otherwise
          # easier to know which hosts your keys have access to.
          HashKnownHosts ${yesOrNo cfg.hashKnownHosts}
        '';
      };
    }

    (optionalAttrs (mode == "NixOS") {
      programs.ssh = {
        inherit (cfg)
          hostKeyAlgorithms
          kexAlgorithms
          macs
          ciphers;
      };
    })

    (optionalAttrs (mode == "home-manager") {
      programs.ssh = {
        enable = true;

        compression = true;
        serverAliveInterval = 20;
        controlMaster = "auto";
        controlPersist = "yes";

        extraConfig = ''
          # Host keys the client accepts - order here is honored by OpenSSH
          ${optionalString (cfg.hostKeyAlgorithms != [ ])
              ("HostKeyAlgorithms " + (concatStringsSep "," cfg.hostKeyAlgorithms))}

          ${optionalString (cfg.kexAlgorithms != [ ])
              ("KexAlgorithms " + (concatStringsSep "," cfg.kexAlgorithms))}
          ${optionalString (cfg.macs != [ ])
              ("MACs " + (concatStringsSep "," cfg.macs))}
          ${optionalString (cfg.ciphers != [ ])
              ("Ciphers " + (concatStringsSep "," cfg.ciphers))}
        '';

        matchBlocks = {
          # special host so ssh into the VM started with nixos-start-vm
          # See soxin/programs/zsh/plugins/functions/nixos-start-vm
          hvm = {
            hostname = "localhost";
            port = 2222;
            forwardAgent = true;
            extraOptions = {
              StrictHostKeyChecking = "no";
            };
          };
        };
      };
    })
  ]);
}
