{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib) mkIf;

  cfg = config.soxincfg.services.k3s;
in
{
  config = mkIf cfg.enable {
    environment.systemPackages =
      let
        inherit (pkgs) nfs-utils;
      in
      [
        # needed for NFS persistent volume
        nfs-utils
      ];
  };
}
