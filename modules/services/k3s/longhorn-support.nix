{ config, pkgs, lib, ... }:

let
  inherit (lib)
    mkIf
    ;

  cfg = config.soxincfg.services.k3s;
in
{
  config = mkIf cfg.enable {
    environment.systemPackages =
      let
        inherit (pkgs)
          util-linux
          ;
      in
      [
        # longhorn requires nsenter, this package provides it
        util-linux
      ];

    # longhorn looks for nsenter in specific paths, /usr/local/bin is one of
    # them so symlink the entire system/bin directory there.
    # https://github.com/longhorn/longhorn/issues/2166#issuecomment-1864656450
    systemd.tmpfiles.rules = [
      "L+ /usr/local/bin - - - - /run/current-system/sw/bin/"
    ];

    services.openiscsi = {
      enable = true;
      name = config.networking.hostName;
    };
  };
}
