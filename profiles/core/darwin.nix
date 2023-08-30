{ soxincfg, inputs, pkgs, soxin, ... }:
{
  # enable the Nix sandbox
  # TODO: Re-enable the sandbox once https://github.com/NixOS/nix/issues/4119 is resolved.
  #nix.settings.sandbox = true;

  # setup NIX_PATH to allow users to access the nixpkgs that built the system
  nix.nixPath = [
    "nixpkgs-unstable=${inputs.nixpkgs-unstable}"
    "nixpkgs=${pkgs.path}"
    "soxin=${soxin}"
    "soxincfg=${soxincfg}"
  ];

  security.pki.certificates = [ soxincfg.vars.assets.nasreddineCA ];

  nix.extraOptions = ''
    extra-platforms = x86_64-darwin aarch64-darwin
    extra-experimental-features = auto-allocate-uids
  '';
  # system = x86_64-darwin

  # set the timeZone
  time.timeZone = "America/Los_Angeles";
}
