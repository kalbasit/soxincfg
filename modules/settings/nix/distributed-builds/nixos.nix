{ config, lib, ... }:

let
  inherit (lib)
    mkIf
    optionals
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
          hostName = "saturn-nixos-vm.bigeye-bushi.ts.net";
          maxJobs = 4;
          sshKey = builtins.toString config.sops.secrets.ssh_key_saturn-nixos-vm.path;
          sshUser = "builder";
          system = "aarch64-linux";
          supportedFeatures = [ "big-parallel" ];
        }
      ]
      ++ optionals (config.networking.hostName != "hercules") [
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
      ];
    };

    sops.secrets = {
      ssh_key_hercules = {
        inherit sopsFile;
      };
      ssh_key_saturn-nixos-vm = {
        inherit sopsFile;
      };
    };
  };
}
