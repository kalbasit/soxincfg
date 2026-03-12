{
  soxincfg,
  inputs,
  pkgs,
  soxin,
  ...
}:
{
  nix = {
    package = pkgs.lixPackageSets.stable.lix;

    settings = {
      # enable the Nix sandbox
      # TODO: Re-enable the sandbox once https://github.com/NixOS/nix/issues/4119 is resolved.
      # sandbox = true;

      substituters = [
        # add my home cache to the list of substituters
        "https://ncps.nasreddine.com"
      ];

      trusted-public-keys = [
        "ncps.bigeye-bushi.ts.net:EYvKWn44YJquaYg2qPevn53ckpSvQmEPSrFoTj5KVdk="
      ];
    };

    # setup NIX_PATH to allow users to access the nixpkgs that built the system
    nixPath = [
      "nixpkgs-unstable=${inputs.nixpkgs-unstable}"
      "nixpkgs=${pkgs.path}"
      "soxin=${soxin}"
      "soxincfg=${soxincfg}"
    ];

    extraOptions = ''
      extra-platforms = x86_64-darwin aarch64-darwin
      extra-experimental-features = auto-allocate-uids
    '';
  };

  # set the timeZone
  time.timeZone = "America/Los_Angeles";
}
