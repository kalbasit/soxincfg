{
  config,
  pkgs,
  soxin,
  soxincfg,
  inputs,
  ...
}:

{
  nix = {
    settings = {
      # enable the Nix sandbox
      sandbox = true;

      substituters = [
        # add my home cache to the list of substituters
        "https://nix-cache.cluster.ifcsn0.nasreddine.com"

        # add nix-community maintained cache
        "https://nix-community.cachix.org"
      ];

      trusted-public-keys = [
        "nix-cache.cluster.nasreddine.com:gAaW+smlYAvg/u94P1XmbI45aIhJ9/5upB5QrKY33B0="
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
      inherit (config.soxincfg.settings.users) userName;
      userAttrs = config.soxincfg.settings.users."${userName}";
    in
    {
      inherit (userAttrs) hashedPassword;

      openssh.authorizedKeys = {
        inherit (userAttrs.authorizedKeys) keys;
      };
    };

  # set the default locale and the timeZone
  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "America/Los_Angeles";

  # set my location narrowed to the USPS Post Office of a nearby town (for privacy)
  location.latitude = 38.5811902710705;
  location.longitude = -121.49817303671485;
}
