{
  config,
  soxincfg,
  lib,
  pkgs,
  ...
}:

let
  prometheusConfig = pkgs.writeText "prometheus-agent.yml" ''
    global:
      scrape_interval: 15s

    scrape_configs:
      - job_name: "macos-laptop"
        static_configs:
          - targets: ["127.0.0.1:9100"]
            labels:
              instance: "${config.networking.hostName}"

    remote_write:
      - url: "https://mimir.mon.nasreddine.com/api/v1/push"
  '';
in
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
      "discord"
      "element"
      "google-drive"
      "gimp"
      "keybase"
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

  # Enable Prometheus node exporter
  services.prometheus.exporters.node = {
    enable = true;
    listenAddress = "127.0.0.1";
  };

  # Start the launchd daemon for the Prometheus agent
  launchd.daemons."prometheus-agent" = {
    script = ''
      # Agent mode requires a Write-Ahead Log (WAL) directory.
      # /tmp is fine since Agent mode is stateless and pushes immediately,
      # but creating it ensures the daemon doesn't crash on startup.
      mkdir -p /tmp/prometheus-agent-wal

      exec ${pkgs.prometheus}/bin/prometheus \
        --config.file=${prometheusConfig} \
        --enable-feature=agent \
        --storage.agent.path=/tmp/prometheus-agent-wal
    '';

    serviceConfig = {
      KeepAlive = true;
      RunAtLoad = true;
      # Optional: Send logs to a file so you can debug if Mimir isn't receiving data
      StandardOutPath = "/var/log/prometheus-agent.log";
      StandardErrorPath = "/var/log/prometheus-agent.log";
    };
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
