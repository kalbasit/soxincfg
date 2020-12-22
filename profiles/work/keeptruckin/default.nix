{ config, lib, mode, ... }:

with lib;

{
  config = mkMerge [
    (optionalAttrs (mode == "NixOS") {
      # Add the extra hosts
      networking.extraHosts = ''
        127.0.0.1 docker.keeptruckin.dev docker.keeptruckin.work
      '';

      nix = {
        binaryCaches = [ "https://nix-cache.corp.ktdev.io" ];
        binaryCachePublicKeys = [ "nix-cache.corp.ktdev.io:/xiDfugzrYzUtdUEIvdYBHy48O0169WYHYb/zMdWgLA=" ];
      };
    })

    (mkIf config.soxincfg.programs.ssh.enable (optionalAttrs (mode == "home-manager") {
      programs.ssh.matchBlocks =
        let
          swmSupportSendEnv = [
            "ZSH_PROFILE"
            "SWM_STORY_NAME"
            "SWM_STORY_BRANCH_NAME"
          ];

          secrets = builtins.fromJSON (builtins.readFile (builtins.toString ./secrets.json));
        in
        {
          demeter = {
            inherit (secrets.hosts.demeter) hostname;
            sendEnv = swmSupportSendEnv;
            extraOptions = {
              RemoteForward = "/run/user/2000/gnupg/S.gpg-agent /run/user/2000/gnupg/S.gpg-agent.extra";
              ExitOnForwardFailure = "yes";
            };
          };

          "${secrets.hosts.util-prod.hostname}" = { inherit (secrets.hosts.util-prod) user; };
          "${secrets.hosts.bastion-stg.hostname}" = { inherit (secrets.hosts.bastion-stg) user; };
          "${secrets.hosts.bastion-prod.hostname}" = { inherit (secrets.hosts.bastion-prod) user; };
          "${secrets.hosts.bastion-prod2.hostname}" = { inherit (secrets.hosts.bastion-prod2) user; };
          "${secrets.hosts.k2dev-pg11.hostname}" = { inherit (secrets.hosts.k2dev-pg11) user proxyJump; };
          "${secrets.hosts.k2dev-pg11-bouncer.hostname}" = { inherit (secrets.hosts.k2dev-pg11-bouncer) user proxyJump; };
          "${secrets.hosts.k2prod-pg11-primary.hostname}" = { inherit (secrets.hosts.k2prod-pg11-primary) user proxyJump; };
          "${secrets.hosts.k2prod-pg11-replica0.hostname}" = { inherit (secrets.hosts.k2prod-pg11-replica0) user proxyJump; };
          "${secrets.hosts.k2prod-pg11-replica1.hostname}" = { inherit (secrets.hosts.k2prod-pg11-replica1) user proxyJump; };
          "${secrets.hosts.k2prod-pg11-replica2.hostname}" = { inherit (secrets.hosts.k2prod-pg11-replica2) user proxyJump; };
          "${secrets.hosts.k2prod-primary-pgb11.hostname}" = { inherit (secrets.hosts.k2prod-primary-pgb11) user proxyJump; };
          "${secrets.hosts.k2prod-primary.hostname}" = { inherit (secrets.hosts.k2prod-primary) user proxyJump; };
          "${secrets.hosts.k2prod-replica0.hostname}" = { inherit (secrets.hosts.k2prod-replica0) user proxyJump; };
          "${secrets.hosts.k2prod-replica1.hostname}" = { inherit (secrets.hosts.k2prod-replica1) user proxyJump; };
          "${secrets.hosts.k2prod-replica2.hostname}" = { inherit (secrets.hosts.k2prod-replica2) user proxyJump; };
          "${secrets.hosts.catchall-ec2-internal.hostname}" = { inherit (secrets.hosts.catchall-ec2-internal) user proxyJump; };
        };
    }))
  ];
}
