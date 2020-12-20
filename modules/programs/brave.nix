{ config, lib, mode, pkgs, ... }:

with lib;
let
  cfg = config.soxincfg.programs.brave;
in
{
  options.soxincfg.programs.brave.enable = mkEnableOption "Install and configure Brave";

  config = mkIf cfg.enable (mkMerge [
    (optionalAttrs (mode == "home-manager") {
      home.file.".config/brave/profiles/personal/.keep".text = "";
      home.packages = with pkgs; [ brave ];
    })
  ]);
}
