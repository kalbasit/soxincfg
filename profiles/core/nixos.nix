{
  config,
  pkgs,
  soxin,
  soxincfg,
  inputs,
  lib,
  mode,
  ...
}:

{
  nix = {
    settings = {
      # enable the Nix sandbox
      sandbox = true;

      substituters = [
        # add my home cache to the list of substituters
        "https://ncps.bigeye-bushi.ts.net"

        # add nix-community maintained cache
        "https://nix-community.cachix.org"
      ];

      trusted-public-keys = [
        "ncps.bigeye-bushi.ts.net:EYvKWn44YJquaYg2qPevn53ckpSvQmEPSrFoTj5KVdk="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
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
      users = soxincfg.vars.users {
        inherit lib mode;
        inherit (config.soxincfg.settings.users) userName;
      };

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
