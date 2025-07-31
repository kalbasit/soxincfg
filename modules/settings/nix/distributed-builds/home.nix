{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkIf;

  inherit (pkgs.hostPlatform) isDarwin;

  sopsFile = ./secrets.sops.yaml;
  homePath = config.home.homeDirectory;

  keyStore = "${homePath}/.config/nix/distributed-builds";

  cfg = config.soxincfg.settings.nix.distributed-builds;
in
{
  config = mkIf cfg.enable {
    sops.secrets = mkIf isDarwin {
      ssh_key_hercules = {
        inherit sopsFile;
        path = "${keyStore}/hercules.key";
      };
      ssh_key_kore = {
        inherit sopsFile;
        path = "${keyStore}/kore.key";
      };
    };
  };
}
