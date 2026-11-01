{ config, lib, ... }:

let
  inherit (lib)
    mkIf
    ;

  cfg = config.soxincfg.programs.iterm2;
in
{
  config = mkIf cfg.enable {
    homebrew = {
      casks = [
        "iterm2"
      ];
    };

    # Point iTerm2 at the preferences home-manager writes to ~/.config/iterm2.
    # nix-darwin writes CustomUserPreferences as the primary user; a
    # `defaults write` in an activation script runs as root and lands in
    # root's domain, which iTerm2 never reads.
    system.defaults.CustomUserPreferences."com.googlecode.iterm2" = {
      LoadPrefsFromCustomFolder = true;
      PrefsCustomFolder = "${config.users.users.${config.system.primaryUser}.home}/.config/iterm2";
    };
  };
}
