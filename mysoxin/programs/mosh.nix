{ mode, config, pkgs, lib, ... }:

with lib;
let
  cfg = config.soxin.programs.mosh;
in
{
  options = {
    soxin.programs.mosh = {
      enable = mkEnableOption ''
        Whether to enable mosh.
        On NixOS, this installs mosh and opens ports 60000 to 61000 in your
        firewall.
        On home-manager, this only install mosh.
      '';
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (optionalAttrs (mode == "NixOS") {
      programs.mosh = {
        enable = true;
      };

      networking.firewall.allowedUDPPortRanges = [
        { from = 60000; to = 61000; }
      ];
    })

    (optionalAttrs (mode == "home-manager") {
      home.packages = [ pkgs.mosh ];
    })
  ]);
}
