{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkIf;

  cfg = config.soxincfg.services.borders;
in
{
  config = mkIf cfg.enable {
    xdg.configFile."borders/bordersrc" = {
      executable = true;

      # TODO: When Nix interacts with launchctl, it gets killed due to
      # segmentation fault. Fix this!
      #
      # onChange = ''
      #   if ! type brew &>/dev/null; then
      #     brew() {
      #       if test -x /opt/homebrew/bin/brew; then
      #         PATH="$PATH:/bin:/usr/bin:/opt/homebrew/bin" brew "$@"
      #       elif test -x /usr/local/bin/brew; then
      #         PATH="$PATH:/bin:/usr/bin:/usr/local/bin" brew "$@"
      #       else
      #         _iError "brew: No such file or directory" >&2
      #         return 1
      #       fi
      #     }
      #   fi
      #
      #   _iNote "Restarting Borders"
      #   brew services restart borders
      # '';

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
