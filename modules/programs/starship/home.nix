{ config, lib, ... }:

let
  cfg = config.soxincfg.programs.starship;
in
{
  imports = [ ./options.nix ];

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      { soxin.programs.starship.enable = true; }

      {
        programs.starship = {
          settings = {
            battery = {
              full_symbol = "🔋 ";
              charging_symbol = "⚡️ ";
              discharging_symbol = "💀 ";
            };
            battery.display = [
              {
                threshold = 10;
                style = "bold red";
              }
              {
                threshold = 15;
                style = "red";
              }
              {
                threshold = 20;
                style = "bold yellow";
              }
              {
                threshold = 30;
                style = "yellow";
              }
              {
                threshold = 100;
                style = "bold green";
              }
            ];
            env_var = {
              variable = "ZSH_PROFILE";
              symbol = "✍  ";
            };
            kubernetes.disabled = false;
            time.disabled = false;
          };
        };
      }
    ]
  );
}
