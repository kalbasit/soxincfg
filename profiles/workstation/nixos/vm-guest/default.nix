{
  home-manager,
  lib,
  mode,
  soxincfg,
  ...
}:

let
  inherit (lib) optionals;

  inherit (home-manager.lib.hm.dag) entryBefore entryAnywhere;
in
{
  imports =
    [
      soxincfg.nixosModules.profiles.neovim
      # soxincfg.nixosModules.profiles.workstation.common
    ]
    ++ optionals (mode == "NixOS") [ ./nixos.nix ]
    ++ optionals (mode == "home-manager") [ ./home.nix ];

  config = {
    soxin = {
      #   hardware = {
      #     bluetooth.enable = true;
      #     fwupd.enable = true;
      #     lowbatt.enable = true;
      #     sound.enable = true;
      #     zsa.enable = true;
      #   };
      #
      #   programs = {
      #     keybase.enable = true;
      #     less.enable = true;
      #     rbrowser = {
      #       enable = true;
      #       setMimeList = true;
      #       browsers = {
      #         "chromium@personal" = entryBefore [ "firefox@personal" ] { };
      #         "firefox@personal" = entryBefore [ "chromium@private" ] { };
      #         "chromium@private" = entryBefore [ "chromium@anya" ] { };
      #         "chromium@anya" = entryAnywhere { };
      #         "chromium@vanya" = entryAnywhere { };
      #         "chromium@tanya" = entryAnywhere { };
      #         "chromium@ihab" = entryAnywhere { };
      #         "chromium@sahar" = entryAnywhere { };
      #       };
      #     };
      #   };
      #
      services = {
        #     caffeine.enable = true;
        #     dunst.enable = true;
        #     networkmanager.enable = true;
        openssh.enable = true;
        #     printing = {
        #       enable = true;
        #       brands = [ "epson" ];
        #     };
        #     xserver.enable = true;
      };
      #
      #   virtualisation = {
      #     docker.enable = true;
      #     libvirtd.enable = true;
      #     virtualbox.enable = true;
      #   };
    };

    soxincfg = {
      # hardware = {
      #   onlykey = {
      #     enable = true;
      #
      #     ssh-support.enable = true;
      #
      #     gnupg-support = {
      #       enable = true;
      #
      #       default-key = "kalbasit@pm.me";
      #
      #       decryption-key-public = ''
      #         -----BEGIN PGP PUBLIC KEY BLOCK-----
      #
      #         mDMEYcAFjRYJKwYBBAHaRw8BAQdAc8wiHhA63ylmi83Ee/qRaQQGUJlTongyPmZz
      #         CiNse++0K1dhZWwgTmFzcmVkZGluZSA8d2FlbC5uYXNyZWRkaW5lQGdtYWlsLmNv
      #         bT6ImQQTFggAQQUJcMgSAAULCQgHAgYVCgkICwIEFgIDAQIeAQIXgAIZARYhBIxn
      #         oCe3ysOYyIggV469ldwUd1WiBQJnOtcKAhsBAAoJEI69ldwUd1WiujAA/0irnKnN
      #         bVcuS98jd1fGJQGnRqo5YWh1P277Gk9hMWH7AP9sgZRnzrML1ypbjJ8U+otT7Ptd
      #         8r1dKXrTj53iLtDvCbQgV2FlbCBOYXNyZWRkaW5lIDxrYWxiYXNpdEBwbS5tZT6I
      #         lgQTFggAPhYhBIxnoCe3ysOYyIggV469ldwUd1WiBQJhwAXaAhsDBQlwyBIABQsJ
      #         CAcCBhUKCQgLAgQWAgMBAh4BAheAAAoJEI69ldwUd1WiEW4A/3EG071ul1kFV1cD
      #         Jd5J6U0Yycbe+4z4oJdnEQWOEC9JAQCHlAUJT8jsxdJsFgbq7deyNvmUrALFwh8M
      #         oXV6pX39ArQlV2FlbCBOYXNyZWRkaW5lIDx3YWVsQG5hc3JlZGRpbmUuY29tPoiW
      #         BBMWCAA+FiEEjGegJ7fKw5jIiCBXjr2V3BR3VaIFAmHABfUCGwMFCXDIEgAFCwkI
      #         BwIGFQoJCAsCBBYCAwECHgECF4AACgkQjr2V3BR3VaJqOwD+Oomz/lpVdDd2mK+e
      #         l2Jn2h4f8qvOeGR1ZIudSdO22UgA/RqF9L91848JKhFOU5h/Ra5r2667R/Yw4R11
      #         EhVffTEKtB5XYWVsIE5hc3JlZGRpbmUgPG1lQGthbGJhcy5pdD6IlgQTFggAPhYh
      #         BIxnoCe3ysOYyIggV469ldwUd1WiBQJhwAYsAhsDBQlwyBIABQsJCAcCBhUKCQgL
      #         AgQWAgMBAh4BAheAAAoJEI69ldwUd1Wij64A/20VmcipGdugNeX9+FfwNhJc2eAh
      #         tbTAto0Mv4bGIwmlAQC7GKuXBlZFZBTC6YWK74yHL+Q24I+WpjkJqP0Ws2RzA7g4
      #         BGHABY0SCisGAQQBl1UBBQEBB0CJBE4hQa+D4ByAWV5SmQdJ5eEg1OE84c4FPOZ3
      #         8uGBAgMBCAeIfgQYFggAJhYhBIxnoCe3ysOYyIggV469ldwUd1WiBQJhwAWNAhsM
      #         BQlwyBIAAAoJEI69ldwUd1WivCMA+QE5L/tBDmQPeRjziccWGTaVx2IL586VBFhJ
      #         oFHe/0wNAQC3so45pmbSq/gNkA/X7zdwtT4aVMbFzOR2nZ28X/gnC7gzBGc61w8W
      #         CSsGAQQB2kcPAQEHQIUfWeLXQlYun0/WmzAsBbDT6TeWD/SCFD5Fes9I5mJQiPUE
      #         GBYKACYWIQSMZ6Ant8rDmMiIIFeOvZXcFHdVogUCZzrXDwIbAgUJaUNEAACBCRCO
      #         vZXcFHdVonYgBBkWCgAdFiEEiP6mvZ+9ob6ykU7k7px+1rpJsc4FAmc61w8ACgkQ
      #         7px+1rpJsc6olwD7BZ9eMC5cnmM6R4c4Mizo0MOtD5A+2+ZQagNiAhS2MHMBAI0Q
      #         C1buJtQh+ob/5H+VyNiRTW3tSurSR9eEdGitPBYAZbEA/2b4atE/GurIlbQf2FWi
      #         SjIL1ZIcAmypXQfXL0Klc5H8AQCtkML4KiIFuwtO1Rdfg9ToR9Etv4RKHkc9dP4m
      #         iT+JAg==
      #         =i8JY
      #         -----END PGP PUBLIC KEY BLOCK-----
      #       '';
      #       decryption-key-slot = 101;
      #       decryption-key-trust = "ultimate";
      #
      #       signing-key-slot = 102;
      #     };
      #   };
      #
      #   yubikey = {
      #     enable = false; # using Onlykey now
      #
      #     gnupg-support = {
      #       enable = true;
      #       extra-socket = true;
      #       default-key = "0x7ED8B6DE75BADCF9";
      #
      #       ssh-support = {
      #         enable = true;
      #         public-certificate-pem = ''
      #           ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC+Pe+dPmFXssGgCYUmKwOHLL7gAlbvUxt64D0C8xL64GI+yjzOaF+zlXVkvpKpwwIwgUwtZLABTsgKfkzEzKZbIPEt9jn8eba/82mKF//TKup2dnpunfux6wMJQAQA/1m9tKtSFJOBbNXkZmtQ3Ewm4T/dJPOr7RnX/eyIIBrfJ9NQoMmSU8MJ8ii2V6nrFi1srZAHb5KVpSSSJJOM9jZs9DQ4FJ5YLTpDVG35KbrpSaYSgQwjnIajQI+yQmYF+/m7KofBgbjYTrZ71VgAjXXd/zXw+Z+kN/CyxDccd35oI/KlX5tIy/Qz3JIlHao1WWMM4cVN9dzJuGdFIi+QBsv2nOzNaCvCGdvguhhWLM1gaXGgVHasoZcNedPasteabg2GJjsQTbc82XXWLkAcDVhrRjvG2sfOTXskneDhZhahavrjs5LE8eq3JsfjVUCJLIK3YyS7T6vN6CAzv3y1r47sshjisG9b3E9L4MDZCKZ2YViaA+oHoEemxOC08m5SaGXJX8tt68MIP9pwva5ESZdwS9pbRjQg7QzIDg6nMRSgw/KleZ7g/vtk/5IxEVtK0vbhjFOjDfY8XzPXEYkxkxmsCytKoGnRFmtTHTNJ/vC0Dz6+KTwRJiF1ZjQzbFHEEo/scs82mx4EXxD6XnpPQkAHmQYTOloUevXX2zrx3rDbfQ== cardno:000609501258
      #         '';
      #       };
      #     };
      #   };
      # };

      programs = {
        # android.enable = true;
        # autorandr.enable = true;
        # brave.enable = true;
        # chromium = {
        #   enable = true;
        #   surfingkeys.enable = true;
        # };
        # dbeaver.enable = true;
        fzf.enable = true;
        git.enable = true;
        # mosh.enable = true;
        pet.enable = true;
        # rofi.enable = true;
        ssh.enable = true;
        starship.enable = true;
        # termite.enable = true;
        tmux.enable = true;
        zsh.enable = true;
      };

      # services = {
      #   sleep-on-lan.enable = true;
      #   xserver.windowManager.i3.enable = true;
      # };

      settings = {
        fonts.enable = true;
        gtk.enable = true;
        # nix.distributed-builds.enable = true;
        # networking.nextdns.enable = true;
      };
    };
  };
}
