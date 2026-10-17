{ config, lib, ... }:

let
  cfg = config.soxincfg.programs.mosh;
in
{
  imports = [ ./options.nix ];

  config = lib.mkIf cfg.enable {
    programs.mosh = {
      enable = true;
    };

    networking.firewall.allowedUDPPortRanges = [
      {
        from = 60000;
        to = 61000;
      }
    ];
  };
}
