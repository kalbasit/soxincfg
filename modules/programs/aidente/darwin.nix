{ config, lib, ... }:

let
  inherit (lib)
    mkIf
    ;

  cfg = config.soxincfg.programs.aidente;
in
{
  config = mkIf cfg.enable {
    homebrew = {
      casks = [
        "aldente"
      ];
    };

    system.activationScripts.userDefaults.text = ''
      echo Configuring AIDente
      defaults write com.apphousekitchen.aldente-pro SUEnableAutomaticChecks -bool true
      defaults write com.apphousekitchen.aldente-pro launchAtLogin -bool true
      defaults write com.apphousekitchen.aldente-pro showDockIcon -bool false
      defaults write com.apphousekitchen.aldente-pro showPercentage -bool true
    '';
  };
}
