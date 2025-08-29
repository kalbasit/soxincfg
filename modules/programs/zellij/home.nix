{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkIf;

  cfg = config.soxincfg.programs.zellij;
in
{
  config = mkIf cfg.enable {
    programs.zellij = {
      enable = true;

      enableZshIntegration = true;

      settings = {
        theme = "catppuccin-macchiato";
      };
    };
  };
}
