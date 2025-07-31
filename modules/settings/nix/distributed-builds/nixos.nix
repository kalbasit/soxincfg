{ config, lib, ... }:

let
  inherit (lib) mkIf;

  cfg = config.soxincfg.settings.nix.distributed-builds;

  sopsFile = ./secrets.sops.yaml;
in
{
  config = mkIf cfg.enable {
    nix = {
      distributedBuilds = true;
      buildMachines = [
        {
          hostName = "hercules.bigeye-bushi.ts.net";
          maxJobs = 15;
          sshKey = builtins.toString config.sops.secrets.ssh_key_hercules.path;
          sshUser = "builder";
          system = "x86_64-linux";
          supportedFeatures = [
            "big-parallel"
            "kvm"
            "nixos-test"
          ];
        }
        {
          hostName = "kore.bigeye-bushi.ts.net";
          maxJobs = 1;
          sshKey = builtins.toString config.sops.secrets.ssh_key_kore.path;
          sshUser = "builder";
          system = "aarch64-linux";
          supportedFeatures = [ ];
        }
      ];
    };

    sops.secrets = {
      ssh_key_hercules = {
        inherit sopsFile;
      };
      ssh_key_kore = {
        inherit sopsFile;
      };
    };
  };
}
