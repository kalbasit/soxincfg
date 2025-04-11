{
  config,
  lib,
  ...
}:

let
  inherit (lib)
    mkIf
    ;

  cfg = config.soxincfg.services.borders;
in
{
  config = mkIf cfg.enable {
    xdg.configFile."borders/bordersrc" = {
      executable = true;

      text = ''
        options=(
          style=round
          width=6.0
          hidpi=off
          active_color=0xffe2e2e3
          inactive_color=0xff414550
        )

        borders "''${options[@]}"
      '';
    };
  };
}
