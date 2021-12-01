{ mode, config, lib, ... }:

with lib;
let
  cfg = config.soxin.services.gpgAgent;
in
{
  options = {
    soxin.services.gpgAgent = {
      enable = mkEnableOption "Whether to enable gpg agent.";

      ssh-support = {
        enable = mkEnableOption "Whether to enable SSH support in the GPG agent.";
        cacheTtl = mkOption {
          default = 7200;
          description = "Default SSH cache TTL.";
        };
      };

      extra-socket = mkEnableOption "Whether to enable an extra socket for the GPG agent. This is useful for enabling GPG forwarding to remote servers.";

      cacheTtl = mkOption {
        default = 7200;
        description = "Default cache TTL.";
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (optionalAttrs (mode == "Nixos") {
      programs.gnupg.agent = {
        enable = true;

        enableSSHSupport = cfg.ssh-support.enable;
        enableExtraSocket = cfg.extra-socket;
      };
    })

    (optionalAttrs (mode == "home-manager") {
      services.gpg-agent = {
        enable = true;

        enableSshSupport = cfg.ssh-support.enable;
        enableExtraSocket = cfg.extra-socket;

        defaultCacheTtl = cfg.cacheTtl;
        maxCacheTtl = cfg.cacheTtl;

        defaultCacheTtlSsh = cfg.ssh-support.cacheTtl;
        maxCacheTtlSsh = cfg.ssh-support.cacheTtl;
      };
    })
  ]);
}
