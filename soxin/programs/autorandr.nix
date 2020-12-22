{ mode, config, pkgs, lib, ... }:

with lib;
let
  cfg = config.soxin.programs.autorandr;
in
{
  options = {
    soxin.programs.autorandr = {
      enable = mkEnableOption "Whether to enable autorandr.";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (optionalAttrs (mode == "NixOS") { services.autorandr.enable = true; })
    (optionalAttrs (mode == "home-manager") { programs.autorandr.enable = true; })
  ]);
}
