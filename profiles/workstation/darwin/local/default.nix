{
  lib,
  mode,
  soxincfg,
  ...
}:

let
  inherit (lib) optionals;
in
{
  imports =
    [
      soxincfg.nixosModules.profiles.neovim
      soxincfg.nixosModules.profiles.workstation.common
    ]
    ++ optionals (mode == "nix-darwin") [ ./darwin.nix ]
    ++ optionals (mode == "home-manager") [ ./home.nix ];

  soxin = {
    programs = {
      less.enable = true;
    };

    virtualisation = {
      docker.enable = true;
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
          decryption-key-trust = "ultimate";

          decryption-key-slot = 101;
          signing-key-slot = 102;
        };
      };
    };

    programs = {
      # android.enable = true;
      # brave.enable = true;
      # chromium = { enable = true; surfingkeys.enable = true; };
      fzf.enable = true;
      git.enable = true;
      mosh.enable = true;
      pet.enable = true;
      ssh.enable = true;
      starship.enable = true;
      tmux.enable = true;
      zsh.enable = true;
    };

    services = {
      borders.enable = true;
      sketchybar.enable = true;
      skhd.enable = true;
      yabai.enable = true;
    };

    settings = {
      fonts.enable = true;
    };
  };
}
