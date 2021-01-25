{ config, lib, mode, pkgs, ... }:

with lib;
let
  cfg = config.soxincfg.programs.android;
in
{
  options.soxincfg.programs.android = {
    enable = mkEnableOption "Enable Android";
  };

  config = mkIf cfg.enable (mkMerge [
    (optionalAttrs (mode == "NixOS") {
      programs.adb.enable = true;
      soxin.users.groups = singleton "adbusers";
    })
  ]);
}
