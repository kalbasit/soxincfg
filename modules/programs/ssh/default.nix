{
  mode,
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib)
    concatStringsSep
    isString
    mkEnableOption
    mkIf
    mkMerge
    mkOption
    mkPackageOption
    optionalAttrs
    optionalString
    types
    ;

  cfg = config.soxincfg.programs.ssh;

  yesOrNo = v: if v then "yes" else "no";
in
{
  # Configuration comes from
  # https://infosec.mozilla.org/guidelines/openssh

  options = {
    soxincfg.programs.ssh = {
      enable = mkEnableOption "enable SSH client";

      enableSSHAgent = mkEnableOption "enable SSH client";

      identitiesOnly = mkOption {
        type = types.bool;
        default = false;
        # TODO: document the man references with docbook
        description = ''
          Specifies that ssh(1) should only use the configured authentication
          identity and certificate files (either the default files, or those
          explicitly configured in the ssh_config files or passed on the ssh(1)
          command-line), even if ssh- agent(1) or a PKCS11Provider or
          SecurityKeyProvider offers more identities. The argument to this
          keyword must be yes or no (the default). This option is intended for
          situations where ssh-agent offers many different identities.
        '';
      };

      identityFiles = mkOption {
        apply = list: map (path: if isString path then path else toString path) list;
        type = types.listOf (types.either types.path types.str);
        default = [ ];
        description = ''
          The identity files to offer all hosts.
        '';
      };

      hashKnownHosts = mkEnableOption "hash known hosts";

      addKeysToAgent = mkOption {
        apply = v: if builtins.isBool v then yesOrNo v else v;
        type = types.either types.bool (
          types.enum [
            "ask"
            "confirm"
          ]
        );
        default = cfg.enableSSHAgent;
        description = ''
          Whether to automatically add a private key that is used during
          authentication to ssh-agent if it is running (with confirmation
          enabled if set to 'confirm'.
        '';
      };

      hostKeyAlgorithms = mkOption {
        type = types.listOf types.str;
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

      package = mkPackageOption pkgs "openssh_gssapi" { example = "pkgs.openssh"; };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (optionalAttrs (mode == "NixOS" || mode == "home-manager") {
      programs.ssh = {
        extraConfig = ''
          PubkeyAuthentication yes

          # Ensure KnownHosts are unreadable if leaked - it is otherwise
          # easier to know which hosts your keys have access to.
          HashKnownHosts ${yesOrNo cfg.hashKnownHosts}

          # Host keys the client accepts - order here is honored by OpenSSH
          ${optionalString (cfg.hostKeyAlgorithms != [ ]) (
            "HostKeyAlgorithms " + (concatStringsSep "," cfg.hostKeyAlgorithms)
          )}

          ${optionalString (cfg.kexAlgorithms != [ ]) (
            "KexAlgorithms " + (concatStringsSep "," cfg.kexAlgorithms)
          )}
          ${optionalString (cfg.macs != [ ]) ("MACs " + (concatStringsSep "," cfg.macs))}
          ${optionalString (cfg.ciphers != [ ]) ("Ciphers " + (concatStringsSep "," cfg.ciphers))}
        '';
      };
    })

    (optionalAttrs (mode == "NixOS") {
      programs.ssh = {
        inherit (cfg)
          ciphers
          hostKeyAlgorithms
          kexAlgorithms
          macs
          package
          ;

        startAgent = cfg.enableSSHAgent;
      };
    })

    (optionalAttrs (mode == "home-manager") {
      programs.ssh = {
        inherit (cfg) package;

        enable = true;

        compression = true;
        serverAliveInterval = 20;
        controlMaster = "auto";
        controlPersist = "yes";

        extraConfig = ''
          IdentitiesOnly=${yesOrNo cfg.identitiesOnly}
          ${optionalString (cfg.identityFiles != [ ]) (
            concatStringsSep "\n" (map (f: "IdentityFile ${f}") cfg.identityFiles)
          )}

          AddKeysToAgent=${cfg.addKeysToAgent}
        '';
      };
    })
  ]);
}
