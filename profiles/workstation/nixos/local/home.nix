{ config, lib, pkgs, ... }:

let
  inherit (lib)
    optionals
    ;
in
{
  # services
  services.clipmenu.enable = true;
  services.flameshot.enable = true;
  services.betterlockscreen = {
    enable = true;
    arguments = [
      "--show-layout"
    ];
  };
}
