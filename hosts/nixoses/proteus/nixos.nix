{
  config,
  soxincfg,
  ...
}:

let
  homePath = config.soxincfg.settings.users.user.home;
  owner = config.soxincfg.settings.users.user.name;
  sopsFile = ./secrets.sops.yaml;
in
{
  imports = [
    soxincfg.nixosModules.profiles.wsl-gaming
  ];

  networking.hostName = "proteus";

  # Reachable over the tailnet. The Windows half of this machine is already the
  # node `proteus`, and a tailscaled in here cannot share that login -- it is a
  # separate node -- so it joins under its own name, the way hercules-arch and
  # hercules-win11 split one box.
  services.tailscale = {
    enable = true;

    # MagicDNS is left on. WSL points /etc/resolv.conf at the shared
    # /mnt/wsl/resolv.conf; with no systemd-resolved here, tailscaled takes the
    # direct path and replaces that symlink with its own file naming
    # 100.100.100.100, and WSL puts the symlink back on the next boot. So tailnet
    # names resolve whenever tailscaled is up and DNS still works when it is not.
    extraSetFlags = [ "--hostname=proteus-wsl" ];
  };

  # sshd, key-only, from mysoxin/services/networking/ssh/sshd.nix. Keys come
  # from vars/users/ssh-keys.nix via profiles/core/nixos.nix. NixOS-WSL masks
  # firewall.service, so there is no port to open.
  soxin.services.openssh.enable = true;

  sops = {
    age.keyFile = "${homePath}/.config/sops/age/keys.txt";

    secrets = {
      _ssh_id_ed25519 = {
        inherit owner sopsFile;
        mode = "0400";
        path = "${homePath}/.ssh/id_ed25519";
      };

      # This host's steward credential. Declared here rather than in the
      # steward module because the module is home-manager and soxin gives
      # sops-nix's module to NixOS hosts -- and because a module-owned secret
      # would be encrypted to every host that enables the module, which would
      # let any of them read the others' credentials and undo the point of
      # issuing one per host.
      #
      # The file holds `STEWARD_TOKEN=...` and is read as an EnvironmentFile,
      # so the token never enters the unit or the nix store.
      steward_env = {
        inherit owner sopsFile;
      };
    };
  };

  # load home-manager configuration
  home-manager.users."${config.soxincfg.settings.users.userName}" = import ./home.nix {
    inherit soxincfg;
  };

  system.stateVersion = "26.05";
}
