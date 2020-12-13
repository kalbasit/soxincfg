{ mode, config, pkgs, lib, ... }:

with lib;
let
  cfg = config.soxin.programs.keybase;
in
{
  options = {
    soxin.programs.keybase = {
      enable = mkEnableOption "Whether to enable Keybase.";
      enableFs = mkEnableOption "Whether to enable Keybase filesystem.";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      services.keybase.enable = true;
      services.kbfs.enable = cfg.enableFs;
    }
  ]);
}
