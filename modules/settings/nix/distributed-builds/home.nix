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
  yl_home = config.home.homeDirectory;

  keyStore = "${yl_home}/.config/nix/distributed-builds";

  cfg = config.soxincfg.settings.nix.distributed-builds;
in
{
  config = mkIf cfg.enable {
    sops.age = mkIf isDarwin {
      generateKey = true;
      keyFile = "${yl_home}/.local/share/soxincfg/sops/age.key";
    };

    sops.secrets = mkIf isDarwin {
      ssh_key_aarch64_nixos_community = {
        inherit sopsFile;
        path = "${keyStore}/aarch64_nixos_community.key";
      };
      ssh_key_kore = {
        inherit sopsFile;
        path = "${keyStore}/kore.key";
      };
    };
  };
}
