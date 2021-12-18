{ config, home-manager, lib, mode, pkgs, ... }:

with lib;

mkMerge [
  {
    soxin = {
      hardware = {
        bluetooth.enable = true;
        fwupd.enable = true;
        lowbatt.enable = true;
        sound.enable = true;
      };

      programs = {
        keybase = {
          enable = true;
          enableFs = true;
        };
        less.enable = true;
        rbrowser = {
          enable = true;
          setMimeList = true;
          browsers = {
            "firefox@personal" = home-manager.lib.hm.dag.entryBefore [ "brave@personal" ] { };
            "brave@personal" = home-manager.lib.hm.dag.entryBefore [ "firefox@private" ] { };
            "firefox@private" = home-manager.lib.hm.dag.entryBefore [ "firefox@anya" ] { };
            "firefox@anya" = home-manager.lib.hm.dag.entryBefore [ "firefox@vanya" ] { };
            "firefox@vanya" = home-manager.lib.hm.dag.entryBefore [ "firefox@tanya" ] { };
            "firefox@tanya" = home-manager.lib.hm.dag.entryBefore [ "firefox@ihab" ] { };
            "firefox@ihab" = home-manager.lib.hm.dag.entryAnywhere { };
          };
        };
        rofi = {
          enable = true;
          i3.enable = true;
        };
      };

      services = {
        caffeine.enable = true;
        dunst.enable = true;
        locker = {
          enable = true;
          color = "ffa500";
          extraArgs = [
            "--clock"
            "--show-failed-attempts"
            "--datestr='%A %Y-%m-%d'"
          ];
        };
        networkmanager.enable = true;
        openssh.enable = true;
        printing = {
          enable = true;
          brands = [ "epson" ];
        };
        xserver.enable = true;
      };

      virtualisation = {
        docker.enable = true;
        libvirtd.enable = true;
        virtualbox.enable = true;
      };
    };

    soxincfg = {
      hardware = {
        onlykey = {
          enable = true;

          ssh-support.enable = true;

          gnupg-support = {
            enable = true;

            default-key = "kalbasit@pm.me";

            decryption-key-public = ''
              -----BEGIN PGP PUBLIC KEY BLOCK-----
              Version: GnuPG v2

              mDMEAAAAABYJKwYBBAHaRw8BAQdADvQ/0JzWUkbBaK/XP+/brxSSmkIT0k8tgSUz
              mOAmz7m0DmthbGJhc2l0QHBtLm1liIAEExYIABwFAgAAAAACCwkCGwMEFQgJCgQW
              AgMBAheAAh4BABYJEEDGXK00GdidCxpUUkVaT1ItR1BH0B4A/ih6bylUpWBQkX8K
              ljuS6i53of8ZfeBzvMmg9yJtZQuRAP46e64HTixFLg5R7dlUnCJgiMA0+UTS3Zw7
              2wvJbM4jArg4BAAAAAASCisGAQQBl1UBBQEBB0AyoiXs7Vh/br5zFMWkIjfVqMXK
              DzfcHEm3z96Fu0YLQwMBCAeIbQQYFggACQUCAAAAAAIbDAAWCRBAxlytNBnYnQsa
              VFJFWk9SLUdQR37VAP9KXabWEj6mt0KMJxWZJ4Yl87rCqyon+SbxyZhSTXGDHAEA
              yG+iXMhIOaXK6D+W2FMzNXiISTSNWXGESv93G3tUBgc=
              =/0wb
              -----END PGP PUBLIC KEY BLOCK-----
            '';
            decryption-key-slot = 132;
            decryption-key-trust = "ultimate";

            signing-key-slot = 132;
            # signing key is the same as decryption key so no need to add it
            # to trust.
          };
        };

        yubikey = {
          enable = false; # using Onlykey now


          gnupg-support = {
            enable = true;
            extra-socket = true;
            default-key = "0x7ED8B6DE75BADCF9";

            ssh-support = {
              enable = true;
              public-certificate-pem = ''
                ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC+Pe+dPmFXssGgCYUmKwOHLL7gAlbvUxt64D0C8xL64GI+yjzOaF+zlXVkvpKpwwIwgUwtZLABTsgKfkzEzKZbIPEt9jn8eba/82mKF//TKup2dnpunfux6wMJQAQA/1m9tKtSFJOBbNXkZmtQ3Ewm4T/dJPOr7RnX/eyIIBrfJ9NQoMmSU8MJ8ii2V6nrFi1srZAHb5KVpSSSJJOM9jZs9DQ4FJ5YLTpDVG35KbrpSaYSgQwjnIajQI+yQmYF+/m7KofBgbjYTrZ71VgAjXXd/zXw+Z+kN/CyxDccd35oI/KlX5tIy/Qz3JIlHao1WWMM4cVN9dzJuGdFIi+QBsv2nOzNaCvCGdvguhhWLM1gaXGgVHasoZcNedPasteabg2GJjsQTbc82XXWLkAcDVhrRjvG2sfOTXskneDhZhahavrjs5LE8eq3JsfjVUCJLIK3YyS7T6vN6CAzv3y1r47sshjisG9b3E9L4MDZCKZ2YViaA+oHoEemxOC08m5SaGXJX8tt68MIP9pwva5ESZdwS9pbRjQg7QzIDg6nMRSgw/KleZ7g/vtk/5IxEVtK0vbhjFOjDfY8XzPXEYkxkxmsCytKoGnRFmtTHTNJ/vC0Dz6+KTwRJiF1ZjQzbFHEEo/scs82mx4EXxD6XnpPQkAHmQYTOloUevXX2zrx3rDbfQ== cardno:000609501258
              '';
            };
          };
        };
      };

      programs = {
        android.enable = true;
        autorandr.enable = true;
        brave.enable = true;
        chromium = { enable = true; surfingkeys.enable = true; };
        dbeaver.enable = true;
        fzf.enable = true;
        git.enable = true;
        mosh.enable = true;
        neovim.enable = true;
        pet.enable = true;
        ssh.enable = true;
        starship.enable = true;
        termite.enable = true;
        tmux.enable = true;
        wezterm.enable = true;
        zsh.enable = true;
      };

      services = {
        xserver.windowManager.i3.enable = true;
      };

      settings = {
        fonts.enable = true;
        gtk.enable = true;
        nix.distributed-builds.enable = true;
      };
    };
  }

  (optionalAttrs (mode == "NixOS")
    (
      let
        sopsFile = ./secrets.sops.yaml;
      in
      {
        environment.homeBinInPath = true;

        # allow the store to be accessed for store paths via SSH
        nix.sshServe = {
          enable = true;
          keys = config.soxincfg.settings.users.users.yl.sshKeys;
        };

        services.gnome.gnome-keyring.enable = true;

        # Enable TailScale for zero-config VPN service.
        services.tailscale.enable = true;

        # Feed the kernel some entropy
        services.haveged.enable = true;

        services.logind = {
          lidSwitch = "hybrid-sleep";
          lidSwitchDocked = "ignore";
          lidSwitchExternalPower = "hybrid-sleep";
          extraConfig = ''
            HandlePowerKey=suspend
          '';
        };

        # Require Password and U2F to login
        security.pam.u2f = {
          enable = true;
          cue = true;
          control = "required";
        };

        # Redshift
        location.latitude = 34.42;
        location.longitude = -122.11;
        services.redshift = {
          brightness.day = "1.0";
          brightness.night = "0.6";
          enable = true;
          temperature.day = 5900;
          temperature.night = 3700;
        };

        # TODO: fix this!
        system.extraSystemBuilderCmds = ''ln -sfn /yl/.surfingkeys.js $out/.surfingkeys.js'';

        # L2TP VPN does not connect without the presence of this file!
        # https://github.com/NixOS/nixpkgs/issues/64965
        system.activationScripts.ipsec-secrets = ''
          touch $out/etc/ipsec.secrets
        '';

        sops.secrets._etc_NetworkManager_system-connections_Nasreddine_nmconnection = { inherit sopsFile; path = "/etc/NetworkManager/system-connections/Nasreddine.nmconnection"; };
        sops.secrets._etc_NetworkManager_system-connections_Nasreddine-ADMIN_nmconnection = { inherit sopsFile; path = "/etc/NetworkManager/system-connections/Nasreddine-ADMIN.nmconnection"; };
        sops.secrets._etc_NetworkManager_system-connections_Ellipsis_Jetpack_4976_nmconnection = { inherit sopsFile; path = "/etc/NetworkManager/system-connections/Ellipsis_Jetpack_4976.nmconnection"; };
        sops.secrets._etc_NetworkManager_system-connections_Wired_connection_nmconnection = { inherit sopsFile; path = "/etc/NetworkManager/system-connections/Wired_connection.nmconnection"; };
      }
    ))

  (optionalAttrs (mode == "home-manager") {
    # programs
    programs.bat.enable = true;
    programs.direnv.enable = true;

    # services
    services.clipmenu.enable = true;
    services.flameshot.enable = true;

    # files
    home.file = {
      ".npmrc".text = "prefix=${config.home.homeDirectory}/.filesystem";
    };

    home.packages = with pkgs; [
      zulip
      zulip-term

      # Switch your X keyboard layouts from the command line
      xkb-switch

      remmina

      file

      dnsutils # for dig

      dosbox
      (retroarch.override {
        cores = with libretro; [
          beetle-psx
          beetle-psx-hw
          beetle-snes
        ];
      })

      imagemagick # for convert

      binutils # for strings

      weechat

      xsel

      eternal-terminal

      # zoom for meetings
      zoom-us

      libnotify

      amazon-ecr-credential-helper
      docker-credential-gcr

      filezilla

      bitwarden-cli

      gdb

      gist

      gnupg

      go

      jq

      jrnl

      killall

      lastpass-cli

      lazygit

      mercurial

      nur.repos.kalbasit.nixify

      nix-index

      nix-review

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

      jetbrains.idea-ultimate
      jetbrains.goland
      bazel

      slack

      glances

      # Games
      _2048-in-terminal

      protonvpn-cli
    ]);
  })
]
