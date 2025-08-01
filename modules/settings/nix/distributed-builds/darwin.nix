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
          hostName = "saturn-nixos-vm.bigeye-bushi.ts.net";
          maxJobs = 4;
          sshKey = "${keyStore}/saturn-nixos-vm.key";
          sshUser = "builder";
          system = "aarch64-linux";
          supportedFeatures = [ "big-parallel" ];
        }
      ];
    };
  };
}
