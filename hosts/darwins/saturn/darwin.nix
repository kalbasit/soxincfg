{
  config,
  soxincfg,
  ...
}:

{
  imports = [
    soxincfg.nixosModules.profiles.myself
    soxincfg.nixosModules.profiles.personal
    soxincfg.nixosModules.profiles.neovim.full
    soxincfg.nixosModules.profiles.workstation.darwin.local
  ];

  homebrew = {
    brews = [
      "ffmpeg" # Used by Audacity to open AAC files
      "qemu" # QEMU backend

      "siderolabs/tap/talosctl"
    ];

    casks = [
      "audacity"
      "autodesk-fusion"
      "obsidian"
      "discord"
      "element"
      "google-drive"
      "gimp"
      "nextcloud"
      "orcaslicer"
      "proton-mail"
      "protonvpn"
      "signal"
      "tor-browser"
      "utm" # QEMU frontend
      "visual-studio-code"
      "tailscale-app"
      "whatsapp"
      "zen"

      "grishka/grishka/neardrop"
    ];

    taps = [
      "grishka/grishka"
      "siderolabs/tap"
    ];
  };

  # Determinate systems uses its own daemon and we shouldn't let nix-darwin manage Nix
  nix.enable = false;

  soxincfg = {
    # Enable Nix Distributed builds
    settings.nix.distributed-builds.enable = true;

    # TODO: Move to the darwin workstation profile
    programs.secretive.enable = true;
    services.ssh-agent-mux.enable = true;
  };

  # load home-manager configuration
  # TODO: Use users.user.name once the following commit is used
  # https://github.com/nix-community/home-manager/commit/216690777e47aa0fb1475e4dbe2510554ce0bc4b
  home-manager.users."${config.soxincfg.settings.users.userName}" = import ./home.nix {
    inherit soxincfg;
  };

  # Inform nix-darwin of the primaryUser
  system.primaryUser = config.soxincfg.settings.users.userName;

  system.stateVersion = 5;
}
