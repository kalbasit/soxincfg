{ pkgs, soxincfg, mode, lib, ... }:
with lib;
let
  nasreddineCA = builtins.readFile (builtins.fetchurl {
    url = "https://s3-us-west-1.amazonaws.com/nasreddine-infra/ca.crt";
    sha256 = "17x45njva3a535czgdp5z43gmgwl0lk68p4mgip8jclpiycb6qbl";
  });
in
{
  config = mkMerge [
    # configure the keyboard
    { soxincfg.settings.keyboard.enable = true; }

    # configure the theme
    { soxin.settings.theme = "gruvbox-dark"; }

    # configure NixOS
    (optionalAttrs (mode == "NixOS") {
      # enable the Nix sandbox but only on Linux
      nix.useSandbox = pkgs.stdenv.hostPlatform.isLinux;

      # setup NIX_PATH to allow users to access the nixpkgs that built the system
      nix.nixPath = singleton "nixpkgs=${pkgs.path}";

      boot.tmpOnTmpfs = true;

      security.pki.certificates = [ nasreddineCA ];

      # Set the ssh authorized keys for the root user
      users.users.root = {
        inherit (soxincfg.vars.users.yl) hashedPassword;

        openssh.authorizedKeys.keys = soxincfg.vars.users.yl.sshKeys;
      };

      # set the default locale and the timeZone
      i18n.defaultLocale = "en_US.UTF-8";
      time.timeZone = "America/Los_Angeles";
    })
  ];
}
