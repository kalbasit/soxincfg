{
  lib,
  soxincfg,
  ...
}:

let
  inherit (lib)
    mkForce
    ;
in
{
  imports = [
    soxincfg.nixosModules.profiles.myself
    soxincfg.nixosModules.profiles.personal
    soxincfg.nixosModules.profiles.neovim
    soxincfg.nixosModules.profiles.workstation.darwin.local
  ];

  homebrew = {
    casks = [
      "autodesk-fusion"
      "obsidian"
      "orcaslicer"
      "protonvpn"
      "synology-drive"
      "tailscale"

      "grishka/grishka/neardrop"
    ];

    taps = [ "grishka/grishka" ];
  };

  # Determinate systems uses its own daemon and we shouldn't let nix-darwin manage Nix
  nix.enable = false;

  # load YL's home-manager configuration
  home-manager.users.wnasreddine = import ./home.nix { inherit soxincfg; };

  # turn off i3-like stuff for now
  soxincfg.services = {
    borders.enable = mkForce false;
    sketchybar.enable = mkForce false;
  };

  system.stateVersion = 5;
}
