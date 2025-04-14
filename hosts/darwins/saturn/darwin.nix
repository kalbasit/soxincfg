{
  soxincfg,
  ...
}:

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
      "proton-mail"
      "protonvpn"
      "synology-drive"
      "tailscale"
      "zen-browser"

      "grishka/grishka/neardrop"
    ];

    taps = [ "grishka/grishka" ];
  };

  # Determinate systems uses its own daemon and we shouldn't let nix-darwin manage Nix
  nix.enable = false;

  # load YL's home-manager configuration
  home-manager.users.wnasreddine = import ./home.nix { inherit soxincfg; };

  system.stateVersion = 5;
}
