# TODO(high): Surfingkeys must be composed of two files, the main one and the colemak bindings.
{ config, lib, mode, pkgs, ... }:

with lib;
let
  cfg = config.soxincfg.programs.chromium;
in
{
  options.soxincfg.programs.chromium.enable = mkEnableOption "Install and configure Chromium";
  options.soxincfg.programs.chromium.surfingkeys.enable = mkEnableOption "Install and configure Surfingkeys";

  config = mkIf cfg.enable (mkMerge [
    (optionalAttrs (mode == "home-manager") {
      home.packages = with pkgs; [ chromium ];
    })

    (mkIf cfg.surfingkeys.enable (optionalAttrs (mode == "home-manager") {
      home.file.".surfingkeys.js".text = builtins.readFile (pkgs.substituteAll {
        src = ./surfingkeys.js;

        home_dir = "${config.home.homeDirectory}";
      });
    }))
  ]);
}
