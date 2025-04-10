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

    system.activationScripts.userDefaults.text = ''
      echo Configuring iTerm2
      defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true
      defaults write com.googlecode.iterm2 PrefsCustomFolder -string ${config.users.users.wnasreddine.home}/.config/iterm2
    '';
  };
}
