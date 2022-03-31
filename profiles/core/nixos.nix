{ pkgs, soxin, soxincfg, inputs, lib, mode, ... }:

let
  nasreddineCA = builtins.readFile (builtins.fetchurl {
    url = "https://s3-us-west-1.amazonaws.com/nasreddine-infra/ca.crt";
    sha256 = "17x45njva3a535czgdp5z43gmgwl0lk68p4mgip8jclpiycb6qbl";
  });

  users = soxincfg.vars.users { inherit lib mode; };
in
{
  # enable the Nix sandbox
  nix.useSandbox = true;

  # setup NIX_PATH to allow users to access the nixpkgs that built the system
  nix.nixPath = [
    "nixpkgs-unstable=${inputs.nixpkgs-unstable}"
    "nixpkgs=${pkgs.path}"
    "soxin=${soxin}"
    "soxincfg=${soxincfg}"
  ];

  boot.tmpOnTmpfs = true;

  security.pki.certificates = [ nasreddineCA ];

  # Set the ssh authorized keys for the root user
  users.users.root = {
    inherit (users.yl) hashedPassword;

    openssh.authorizedKeys.keys = users.yl.sshKeys;
  };

  # set the default locale and the timeZone
  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "America/Los_Angeles";
}
