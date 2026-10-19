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
    {
      programs.zsh.shellInit = mkAfter ''
        if [ -z "$INSIDE_EMACS" ]; then
          eval "$(${pkgs.starship}/bin/starship init zsh)"
        fi
      '';
    }

    { }
  ]);
}
