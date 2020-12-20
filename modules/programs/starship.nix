{ mode, config, pkgs, lib, ... }:

with lib;
let
  cfg = config.soxincfg.programs.starship;
in
{
  options = {
    soxincfg.programs.starship = {
      enable = mkEnableOption "Whether to enable starship prompt.";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (optionalAttrs (mode == "NixOS") {
      programs.zsh.shellInit = mkAfter ''
        if [ -z "$INSIDE_EMACS" ]; then
          eval "$(${pkgs.starship}/bin/starship init zsh)"
        fi
      '';
    })

    (optionalAttrs (mode == "home-manager") {
      programs.starship = {
        enable = true;
        enableZshIntegration = true;
        settings = {
          add_newline = false;
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
