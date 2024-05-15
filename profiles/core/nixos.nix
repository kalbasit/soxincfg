{ pkgs, soxin, soxincfg, inputs, lib, mode, ... }:

let
  users = soxincfg.vars.users { inherit lib mode; };
in
{
  # enable the Nix sandbox
  nix.settings.sandbox = true;

  # setup NIX_PATH to allow users to access the nixpkgs that built the system
  nix.nixPath = [
    "nixpkgs-unstable=${inputs.nixpkgs-unstable}"
    "nixpkgs=${pkgs.path}"
    "soxin=${soxin}"
    "soxincfg=${soxincfg}"
  ];

  boot.tmp.useTmpfs = true;

  # Set the ssh authorized keys for the root user
  users.users.root = {
    inherit (users.yl) hashedPassword;

    openssh.authorizedKeys.keys = users.yl.sshKeys;
  };

  # set the default locale and the timeZone
  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "America/Los_Angeles";
}
