{ mode, config, pkgs, lib, ... }:

let
  inherit (lib)
    concatStringsSep
    isString
    mkDefault
    mkEnableOption
    mkIf
    mkMerge
    mkOption
    optionalAttrs
    optionalString
    singleton
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

      hostKeyAlgorithms = mkOption {
        type = with types; types.listOf types.str;
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
      };
    }

    (mkIf config.soxin.hardware.yubikey.enable {
      soxincfg.programs.ssh = {
        identitiesOnly = mkDefault true;
        identityFiles = singleton (pkgs.writeText "id_rsa.pub" ''
          ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC+Pe+dPmFXssGgCYUmKwOHLL7gAlbvUxt64D0C8xL64GI+yjzOaF+zlXVkvpKpwwIwgUwtZLABTsgKfkzEzKZbIPEt9jn8eba/82mKF//TKup2dnpunfux6wMJQAQA/1m9tKtSFJOBbNXkZmtQ3Ewm4T/dJPOr7RnX/eyIIBrfJ9NQoMmSU8MJ8ii2V6nrFi1srZAHb5KVpSSSJJOM9jZs9DQ4FJ5YLTpDVG35KbrpSaYSgQwjnIajQI+yQmYF+/m7KofBgbjYTrZ71VgAjXXd/zXw+Z+kN/CyxDccd35oI/KlX5tIy/Qz3JIlHao1WWMM4cVN9dzJuGdFIi+QBsv2nOzNaCvCGdvguhhWLM1gaXGgVHasoZcNedPasteabg2GJjsQTbc82XXWLkAcDVhrRjvG2sfOTXskneDhZhahavrjs5LE8eq3JsfjVUCJLIK3YyS7T6vN6CAzv3y1r47sshjisG9b3E9L4MDZCKZ2YViaA+oHoEemxOC08m5SaGXJX8tt68MIP9pwva5ESZdwS9pbRjQg7QzIDg6nMRSgw/KleZ7g/vtk/5IxEVtK0vbhjFOjDfY8XzPXEYkxkxmsCytKoGnRFmtTHTNJ/vC0Dz6+KTwRJiF1ZjQzbFHEEo/scs82mx4EXxD6XnpPQkAHmQYTOloUevXX2zrx3rDbfQ== cardno:000609501258
        '');
      };
    })

    (optionalAttrs (mode == "NixOS") {
      programs.ssh = {
        inherit (cfg)
          hostKeyAlgorithms
          kexAlgorithms
          macs
          ciphers;

        startAgent = cfg.enableSSHAgent;
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
          IdentitiesOnly=${yesOrNo cfg.identitiesOnly}
          ${optionalString (cfg.identityFiles != [ ])
          (concatStringsSep "\n" (map (f: "IdentityFile ${f}") cfg.identityFiles))
          }
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
