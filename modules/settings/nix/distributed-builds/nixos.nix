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
      ssh_key_kore = {
        inherit sopsFile;
      };
    };
  };
}
