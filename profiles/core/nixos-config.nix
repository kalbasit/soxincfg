{
  config,
  pkgs,
  soxin,
  soxincfg,
  inputs,
  lib,
  ...
}:

{
  nix = {
    package = pkgs.lixPackageSets.stable.lix;

    settings = {
      # enable the Nix sandbox
      sandbox = true;
    };

    # setup NIX_PATH to allow users to access the nixpkgs that built the system
    nixPath = [
      "nixpkgs-unstable=${inputs.nixpkgs-unstable}"
      "nixpkgs=${pkgs.path}"
      "soxin=${soxin}"
      "soxincfg=${soxincfg}"
    ];
  };

  boot.tmp.useTmpfs = true;

  # Set the ssh authorized keys for the root user
  users.users.root =
    let
      users = soxincfg.vars.users.nixos config.soxincfg.settings.users.userName;

      inherit (config.soxincfg.settings.users) userName;
      userAttrs = users."${userName}";
    in
    {
      inherit (userAttrs) hashedPassword;

      openssh.authorizedKeys.keys = userAttrs.sshKeys;
    };

  # set the default locale and the timeZone
  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "America/Los_Angeles";

  # set my location narrowed to the USPS Post Office of a nearby town (for privacy)
  location.latitude = 38.5811902710705;
  location.longitude = -121.49817303671485;
}
