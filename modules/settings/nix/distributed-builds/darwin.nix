{ config, lib, ... }:

let
  inherit (lib) mkIf;

  cfg = config.soxincfg.settings.nix.distributed-builds;

  keyStore = "${config.users.users.wnasreddine.home}/.config/nix/distributed-builds";

in
{
  config = mkIf cfg.enable {
    nix = {
      distributedBuilds = true;
      buildMachines = [
        {
          hostName = "kore.bigeye-bushi.ts.net";
          maxJobs = 1;
          sshKey = "${keyStore}/kore.key";
          sshUser = "builder";
          system = "aarch64-linux";
          supportedFeatures = [ ];
        }
      ];
    };
  };
}
