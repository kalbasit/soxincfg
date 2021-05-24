{ mode, config, pkgs, lib, ... }:

with lib;
let
  cfg = config.soxincfg.programs.mosh;
in
{
  options = {
    soxincfg.programs.mosh = {
      enable = mkEnableOption ''
        Whether to enable mosh.
        </para><para>
        On NixOS, this installs mosh and opens ports 60000 to 61000 in your firewall.
        </para><para>
        On home-manager, this only install mosh.
      '';
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (optionalAttrs (mode == "NixOS") {
      programs.mosh = { enable = true; };

      networking.firewall.allowedUDPPortRanges = [{ from = 60000; to = 61000; }];
    })

    (optionalAttrs (mode == "home-manager") { home.packages = [ pkgs.mosh ]; })
  ]);
}
