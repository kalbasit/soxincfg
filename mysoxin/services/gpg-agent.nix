{ mode, config, lib, ... }:

with lib;
let
  cfg = config.soxin.services.gpgAgent;
in
{
  options = {
    soxin.services.gpgAgent = {
      enable = mkEnableOption "Whether to enable gpg agent.";

      cacheTtl = mkOption {
        default = 7200;
        description = "Default cache TTL.";
      };

      cacheTtlSsh = mkOption {
        default = 7200;
        description = "Default SSH cache TTL.";
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (optionalAttrs (mode == "Nixos") {
      programs.gnupg.agent = {
        enable = true;

        enableSSHSupport = true;
        enableExtraSocket = true;
      };
    })

    (optionalAttrs (mode == "home-manager") {
      services.gpg-agent = {
        enable = true;

        enableSshSupport = true;
        enableExtraSocket = true;

        defaultCacheTtl = cfg.cacheTtl;
        maxCacheTtl = cfg.cacheTtl;
        defaultCacheTtlSsh = cfg.cacheTtlSsh;
        maxCacheTtlSsh = cfg.cacheTtlSsh;
      };
    })
  ]);
}
