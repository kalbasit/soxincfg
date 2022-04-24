{ soxincfg, inputs, pkgs, soxin, ... }:
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

  security.pki.certificates = [ soxincfg.vars.assets.nasreddineCA ];

  nix.extraOptions = ''
    extra-platforms = x86_64-darwin aarch64-darwin
  '';
  # system = x86_64-darwin

  # set the timeZone
  time.timeZone = "America/Los_Angeles";
}
