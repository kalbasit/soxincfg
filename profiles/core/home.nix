{ lib, ... }:

{
  imports = [ ./home-config.nix ];

  # configure the keyboard
  soxincfg.settings.keyboard.enable = true;

  # configure the theme
  soxin.settings.theme = "gruvbox-dark";
}
