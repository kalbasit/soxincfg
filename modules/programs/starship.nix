{ mode, config, pkgs, lib, ... }:

with lib;
let
  cfg = config.soxincfg.programs.starship;
in
{
  options = {
    soxincfg.programs.starship = {
      enable = mkEnableOption "starship prompt";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    { soxin.programs.starship.enable = true; }

    (optionalAttrs (mode == "home-manager") {
      programs.starship = {
        settings = {
          battery.display = [
            { threshold = 100; style = "bold green"; }
            { threshold = 30; style = "yellow"; }
            { threshold = 20; style = "bold yellow"; }
            { threshold = 15; style = "red"; }
            { threshold = 10; style = "bold red"; }
          ];
          env_var = {
            variable = "ZSH_PROFILE";
            symbol = "✍  ";
          };
          kubernetes.disabled = false;
        };
      };
    })
  ]);
}
