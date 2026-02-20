{
  config,
  soxincfg,
  lib,
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
      "antigravity" # Google's AI Editor
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

  nix = {
    distributedBuilds = true;
    buildMachines =
      let
        keyStore = "${config.users.users.wnasreddine.home}/.config/nix/distributed-builds";
      in
      lib.mkForce [
        {
          hostName = "hercules.bigeye-bushi.ts.net";
          maxJobs = 15;
          sshKey = "${keyStore}/hercules.key";
          sshUser = "builder";
          system = "x86_64-linux";
          supportedFeatures = [
            "big-parallel"
            "kvm"
            "nixos-test"
          ];
        }
        {
          hostName = "192.168.64.7";
          maxJobs = 4;
          sshKey = "${keyStore}/saturn-nixos-vm.key";
          sshUser = "builder";
          system = "aarch64-linux";
          supportedFeatures = [ "big-parallel" ];
        }
      ];
  };

  # Enable Nix Distributed builds
  soxincfg.settings.nix.distributed-builds.enable = true;

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
