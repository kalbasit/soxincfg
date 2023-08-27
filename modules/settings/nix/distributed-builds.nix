{ config, lib, mode, pkgs, ... }:

with lib;
let
  cfg = config.soxincfg.settings.nix.distributed-builds;
in
{
  options.soxincfg.settings.nix.distributed-builds.enable = mkEnableOption "Configure Nix distributed-builds";

  config = mkIf cfg.enable (mkMerge [
    # We only need to setup sops if sops was enabled.
    # TODO: Consider an assertion
    (optionalAttrs (mode == "NixOS") {
      nix = {
        distributedBuilds = true;
        buildMachines = [
          # {
          #   hostName = "zeus.admin.nasreddine.com";
          #   sshUser = "builder";
          #   sshKey = builtins.toString config.sops.secrets.ssh_key_zeus.path;
          #   system = "x86_64-linux";
          #   maxJobs = 8;
          #   supportedFeatures = [ ];
          #   mandatoryFeatures = [ ];
          # }

          {
            hostName = "aarch64.nixos.community";
            maxJobs = 64;
            sshKey = builtins.toString config.sops.secrets.ssh_key_aarch64_nixos_community.path;
            sshUser = "kalbasit";
            system = "aarch64-linux";
            supportedFeatures = [ "big-parallel" ];
          }

          # {
          #   hostName = "kore.wael-nasreddine.gmail.com.beta.tailscale.net";
          #   maxJobs = 1;
          #   sshKey = builtins.toString config.sops.secrets.ssh_key_kore.path;
          #   sshUser = "builder";
          #   system = "aarch64-linux";
          #   supportedFeatures = [ ];
          # }

          # {
          #   hostName = "aarch64-linux-0.wael-nasreddine.gmail.com.beta.tailscale.net";
          #   maxJobs = 6;
          #   sshKey = builtins.toString config.sops.secrets.ssh_key_aarch64-linux-0.path;
          #   sshUser = "builder";
          #   system = "aarch64-linux";
          #   supportedFeatures = [ ];
          # }

          # {
          #   hostName = "x86-64-linux-0.wael-nasreddine.gmail.com.beta.tailscale.net";
          #   maxJobs = 6;
          #   sshKey = builtins.toString config.sops.secrets.ssh_key_x86-64-linux-0.path;
          #   sshUser = "builder";
          #   system = "x86_64-linux";
          #   supportedFeatures = [ ];
          # }
        ];
      };

      sops.secrets.ssh_key_aarch64-linux-0.sopsFile = ./secrets.sops.yaml;
      sops.secrets.ssh_key_aarch64_nixos_community.sopsFile = ./secrets.sops.yaml;
      sops.secrets.ssh_key_kore.sopsFile = ./secrets.sops.yaml;
      sops.secrets.ssh_key_x86-64-linux-0.sopsFile = ./secrets.sops.yaml;
      sops.secrets.ssh_key_zeus.sopsFile = ./secrets.sops.yaml;
    })
  ]);
}
