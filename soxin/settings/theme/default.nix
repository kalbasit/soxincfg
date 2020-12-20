{ lib, ... }:

with lib;

{
  options = {
    soxin.settings.theme = mkOption {
      type = types.enum [ "seoul256-dark" "gruvbox-dark" ];
      default = "gruvbox-dark";
      description = ''
        Select the theme to be applied to all the supported applications
      '';
    };
  };

  imports = [
    ./gruvbox
    ./seoul256-dark
  ];
}
