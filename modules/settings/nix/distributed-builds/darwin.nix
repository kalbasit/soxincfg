{ config, lib, ... }:

let
  inherit (lib) mkIf;

  cfg = config.soxincfg.settings.nix.distributed-builds;

  keyStore = "${config.users.users.yl.home}/.config/nix/distributed-builds";
in
{
  config = mkIf cfg.enable {
    nix = {
      distributedBuilds = true;
      buildMachines = [
        {
          hostName = "aarch64.nixos.community";
          maxJobs = 64;
          sshKey = "${keyStore}/aarch64_nixos_community.key";
          sshUser = "kalbasit";
          system = "aarch64-linux";
          supportedFeatures = [ "big-parallel" ];
        }

        # {
        #   hostName = "kore.wael-nasreddine.gmail.com.beta.tailscale.net";
        #   maxJobs = 1;
        #   sshKey = "${keyStore}/kore.key";
        #   sshUser = "builder";
        #   system = "aarch64-linux";
        #   supportedFeatures = [ ];
        # }
      ];
    };
  };
}
