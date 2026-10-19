{
  config,
  pkgs,
  lib,
  ...
}:

with lib;
let
  cfg = config.soxin.programs.starship;
in
{
  options = {
    soxin.programs.starship = {
      enable = mkEnableOption "starship prompt";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    { }

    {
      programs.starship = {
        enable = true;
        enableZshIntegration = config.soxin.programs.zsh.enable;
      };
    }
  ]);
}
