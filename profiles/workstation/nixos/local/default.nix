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

              mDMEYcAFjRYJKwYBBAHaRw8BAQdAc8wiHhA63ylmi83Ee/qRaQQGUJlTongyPmZz
              CiNse++0JldhZWwgTmFzcmVkZGluZSA8d2FlbEBrZWVwdHJ1Y2tpbi5jb20+iJYE
              ExYIAD4WIQSMZ6Ant8rDmMiIIFeOvZXcFHdVogUCYcAGBAIbAwUJcMgSAAULCQgH
              AgYVCgkICwIEFgIDAQIeAQIXgAAKCRCOvZXcFHdVoiqLAQCmSz+RSySWE94gTM3M
              rXCGQoaxKlI1HcUSGNz+A2jIsgD/Uw4e3UWxu78ROFUl2+8ktcxYUp05F/r8jdR1
              8V3cLwy0K1dhZWwgTmFzcmVkZGluZSA8d2FlbC5uYXNyZWRkaW5lQGdtYWlsLmNv
              bT6IlgQTFggAPhYhBIxnoCe3ysOYyIggV469ldwUd1WiBQJhwAWNAhsDBQlwyBIA
              BQsJCAcCBhUKCQgLAgQWAgMBAh4BAheAAAoJEI69ldwUd1WinnQA/RSwspJK38HD
              SHzxzK3GQGTgBn48/Z3TXjtFfvELdgGQAQDTvdUKqptO3Dc8yY150c/xMrDZt+/s
              4Xf87E5g7KL6CLQgV2FlbCBOYXNyZWRkaW5lIDxrYWxiYXNpdEBwbS5tZT6IlgQT
              FggAPhYhBIxnoCe3ysOYyIggV469ldwUd1WiBQJhwAXaAhsDBQlwyBIABQsJCAcC
              BhUKCQgLAgQWAgMBAh4BAheAAAoJEI69ldwUd1WiEW4A/3EG071ul1kFV1cDJd5J
              6U0Yycbe+4z4oJdnEQWOEC9JAQCHlAUJT8jsxdJsFgbq7deyNvmUrALFwh8MoXV6
              pX39ArQlV2FlbCBOYXNyZWRkaW5lIDx3YWVsQG5hc3JlZGRpbmUuY29tPoiWBBMW
              CAA+FiEEjGegJ7fKw5jIiCBXjr2V3BR3VaIFAmHABfUCGwMFCXDIEgAFCwkIBwIG
              FQoJCAsCBBYCAwECHgECF4AACgkQjr2V3BR3VaJqOwD+Oomz/lpVdDd2mK+el2Jn
              2h4f8qvOeGR1ZIudSdO22UgA/RqF9L91848JKhFOU5h/Ra5r2667R/Yw4R11EhVf
              fTEKtB5XYWVsIE5hc3JlZGRpbmUgPG1lQGthbGJhcy5pdD6IlgQTFggAPhYhBIxn
              oCe3ysOYyIggV469ldwUd1WiBQJhwAYsAhsDBQlwyBIABQsJCAcCBhUKCQgLAgQW
              AgMBAh4BAheAAAoJEI69ldwUd1Wij64A/20VmcipGdugNeX9+FfwNhJc2eAhtbTA
              to0Mv4bGIwmlAQC7GKuXBlZFZBTC6YWK74yHL+Q24I+WpjkJqP0Ws2RzA7QdV2Fl
              bCBOYXNyZWRkaW5lIDxtZUB5bC5jb2Rlcz6IlgQTFggAPhYhBIxnoCe3ysOYyIgg
              V469ldwUd1WiBQJhwAY5AhsDBQlwyBIABQsJCAcCBhUKCQgLAgQWAgMBAh4BAheA
              AAoJEI69ldwUd1WiPesA/0ltEdlFYsgBlond2/9DOFzJbZMpptE6hUkgQDKkfzK5
              AQD6cGm2vepyhRUSbhi/3IOU964ZDBIU4ca6Qn/cS6YhAbg4BGHABY0SCisGAQQB
              l1UBBQEBB0CJBE4hQa+D4ByAWV5SmQdJ5eEg1OE84c4FPOZ38uGBAgMBCAeIfgQY
              FggAJhYhBIxnoCe3ysOYyIggV469ldwUd1WiBQJhwAWNAhsMBQlwyBIAAAoJEI69
              ldwUd1WivCMA+QE5L/tBDmQPeRjziccWGTaVx2IL586VBFhJoFHe/0wNAQC3so45
              pmbSq/gNkA/X7zdwtT4aVMbFzOR2nZ28X/gnCw==
              =IvCC
              -----END PGP PUBLIC KEY BLOCK-----
            '';
            decryption-key-slot = 101;
            decryption-key-trust = "ultimate";

            signing-key-slot = 102;
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

        # Enable dconf required by most guis
        programs.dconf.enable = true;

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
    services.betterlockscreen = {
      enable = true;
      arguments = [
        "--show-layout"
      ];
    };

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
