{ config, lib, mode, pkgs, ... }:

with lib;

mkMerge [
  {
    soxin = {
      hardware = { fwupd.enable = true; };

      programs = {
        keybase = {
          enable = true;
          enableFs = true;
        };
        less.enable = true;
      };

      services = { openssh.enable = true; };

      virtualisation = {
        docker.enable = true;
        libvirtd.enable = true;
      };
    };

    soxincfg = {
      programs = {
        fzf.enable = true;
        git = {
          enable = true;

          # No need to attempt to sign commits via GnuPG as it really does not
          # work well, yet.
          enableGpgSigningKey = mkForce false;
        };
        mosh.enable = true;
        neovim.enable = true;
        pet.enable = true;
        ssh = {
          enable = true;

          # XXX: Remote machines do not have any keys (or shouldn't) and must use my SSH agent instead.
          identitiesOnly = mkForce false;
        };
        starship.enable = true;
        tmux.enable = true;
        zsh.enable = true;
      };

      settings = {
        nix.distributed-builds.enable = true;
      };
    };
  }

  (optionalAttrs (mode == "NixOS") {
    environment.homeBinInPath = true;

    services.eternal-terminal.enable = true;

    # Enable TailScale for zero-config VPN service.
    services.tailscale.enable = true;

    # Allow the forwarding of the GnuPG extra socket.
    # https://wiki.gnupg.org/AgentForwarding
    services.openssh.extraConfig = ''
      StreamLocalBindUnlink yes
    '';

    # L2TP VPN does not connect without the presence of this file!
    # https://github.com/NixOS/nixpkgs/issues/64965
    system.activationScripts.ipsec-secrets = ''
      touch $out/etc/ipsec.secrets
    '';

    # While creating the user runtime directories, create the gnupg directories
    # as well if the user is YL.
    # This is meant to solve this ssh issue:
    #
    #  > ssh zeus
    #  Error: remote port forwarding failed for listen path /run/user/2000/gnupg/S.gpg-agent
    systemd.services."user-runtime-dir@".serviceConfig.ExecStartPost = with pkgs;
      let
        script = writeScript "create-run-user-gnupg.sh" ''
          #!${runtimeShell}
          set -euo pipefail

          if [[ "$1" != "${builtins.toString config.users.users.yl.uid}" ]]; then exit 0; fi

          mkdir -m 700 /run/user/$1/gnupg
          chown $1 /run/user/$1/gnupg
        '';
      in
      "${script} %i";
  })

  (optionalAttrs (mode == "home-manager") {
    programs.bat.enable = true;
    programs.direnv.enable = true;

    home.file = {
      ".npmrc".text = "prefix=${config.home.homeDirectory}/.filesystem";

      ".gnupg/gpg.conf".text = ''
        # NOTE: https://github.com/jclement/dotfiles/blob/master/other/gpg.conf
        #
        # This is an implementation of the Riseup OpenPGP Best Practices
        # https://help.riseup.net/en/security/message-security/openpgp/best-practices
        #

        #-----------------------------
        # default key
        #-----------------------------

        # The default key to sign with. If this option is not used, the default key is
        # the first key found in the secret keyring

        default-key 0x7ED8B6DE75BADCF9

        #-----------------------------
        # behavior
        #-----------------------------

        # Disable inclusion of the version string in ASCII armored output
        no-emit-version

        # Disable comment string in clear text signatures and ASCII armored messages
        no-comments

        # Disable auto-starting the agent. On hosts that I'm using the GnuPG, I'd like
        # to have home-manager start the agent on login.
        no-autostart

        # Display long key IDs
        keyid-format 0xlong

        # List all keys (or the specified ones) along with their fingerprints
        with-fingerprint

        # Display the calculated validity of user IDs during key listings
        list-options show-uid-validity
        verify-options show-uid-validity

        #-----------------------------
        # keyserver
        #-----------------------------

        # This is the server that --recv-keys, --send-keys, and --search-keys will
        # communicate with to receive keys from, send keys to, and search for keys on
        keyserver hkps://hkps.pool.sks-keyservers.net

        # When using --refresh-keys, if the key in question has a preferred keyserver
        # URL, then disable use of that preferred keyserver to refresh the key from
        keyserver-options no-honor-keyserver-url

        # When searching for a key with --search-keys, include keys that are marked on
        # the keyserver as revoked
        keyserver-options include-revoked

        #-----------------------------
        # algorithm and ciphers
        #-----------------------------

        # list of personal digest preferences. When multiple digests are supported by
        # all recipients, choose the strongest one
        personal-cipher-preferences AES256 AES192 AES CAST5

        # list of personal digest preferences. When multiple ciphers are supported by
        # all recipients, choose the strongest one
        personal-digest-preferences SHA512 SHA384 SHA256 SHA224

        # message digest algorithm used when signing a key
        cert-digest-algo SHA512

        # This preference list is used for new keys and becomes the default for
        # "setpref" in the edit menu
        default-preference-list SHA512 SHA384 SHA256 SHA224 AES256 AES192 AES CAST5 ZLIB BZIP2 ZIP Uncompressed
      '';
    };

    home.packages = with pkgs; [
      weechat

      amazon-ecr-credential-helper
      docker-credential-gcr

      gist

      gnupg

      go

      jq

      killall

      lastpass-cli

      mercurial

      nur.repos.kalbasit.nixify

      nix-index

      # curses-based file manager
      lf

      nur.repos.kalbasit.swm

      vgo2nix

      unzip

      nix-zsh-completions
    ] ++ (optionals stdenv.isLinux [
      #
      # Linux applications
      #

      # XXX: Failing to compile on Darwin
      gotop

      slack

      glances

      # Games
      _2048-in-terminal
    ]);
  })
]
