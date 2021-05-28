{ config, lib, mode, pkgs, ... }:

with lib;
let
  cfg = config.soxincfg.programs.onlykey;
in
{
  options.soxincfg.programs.onlykey = {
    enable = mkEnableOption "programs.onlykey";
  };

  config = mkIf cfg.enable (mkMerge [
    (optionalAttrs (mode == "home-manager") {
      home.packages = with pkgs; [ onlykey-cli ];
    })

    (optionalAttrs (mode == "NixOS") {
      hardware.onlykey.enable = true;
    })
  ]);
}
