{
  mode,
  config,
  pkgs,
  lib,
  ...
}:

with lib;
let
  cfg = config.soxin.services.printing;
in
{
  options = {
    soxin.services.printing = {
      enable = mkEnableOption ''
        Whether to enable printing support through the CUPS daemon.
      '';

      autoDiscovery = recursiveUpdate (mkEnableOption ''
        Enable autodiscovery of printers in the local network.
      '') { default = true; };

      brands = mkOption {
        type = with types; listOf (enum (attrNames cfg.brandsPackages));
        default = [ ];
        description = ''
          List of brands' drivers to be installed as CUPS drivers.
        '';
      };

      brandsPackages = mkOption {
        type = with types; attrsOf (listOf types.path);
        default = { };
        description = ''
          List of drivers associated with brands.
        '';
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      soxin.services.printing = {
        brandsPackages = {
          hp = mkDefault [ pkgs.hplip ];
          epson = mkDefault [ pkgs.epson-escpr ];
        };
      };
    }

    (optionalAttrs (mode == "NixOS") {
      services.printing = {
        enable = true;
        drivers = flatten (attrValues (filterAttrs (n: _: any (e: e == n) cfg.brands) cfg.brandsPackages));
      };

      services.avahi = mkIf cfg.autoDiscovery {
        enable = true;
        nssmdns4 = true;
      };
    })
  ]);
}
