{ config, lib, ... }:

let
  inherit (lib)
    mkIf
    ;

  cfg = config.soxincfg.settings.nix.distributed-builds;

  sopsFile = ./secrets.sops.yaml;
in
{
  config = mkIf cfg.enable {
    nix = {
      distributedBuilds = true;
      buildMachines = [
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
      ];
    };

    sops.secrets = {
      ssh_key_aarch64_nixos_community = { inherit sopsFile; };
      ssh_key_kore = { inherit sopsFile; };
    };
  };
}
