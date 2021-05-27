{ mode, config, pkgs, lib, ... }:

with lib;
let
  cfg = config.soxincfg.settings.keyboard;

  colemakLayout = {
    x11 = { layout = "us"; variant = "colemak"; };
    console = { keyMap = "colemak"; };
  };

  usLayout = {
    x11 = { layout = "us"; };
  };
in
{
  options = {
    soxincfg.settings.keyboard = {
      enable = mkEnableOption "default settings for keyboard";

      zsa.enable =
        recursiveUpdate
        (mkEnableOption "support for keyboards from ZSA like the ErgoDox EZ, Planck EZ and Moonlander Mark I")
        { default = true; };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    { soxin.settings.keyboard.layouts = singleton colemakLayout; }

    (optionalAttrs (mode == "NixOS") (mkIf cfg.zsa.enable  {
      services.udev.packages = singleton pkgs.zsa-auto-us-layout-switcher;
    }))

    (optionalAttrs (mode == "NixOS") {
      hardware.keyboard.zsa.enable = true;
      environment.systemPackages = with pkgs; [ wally-cli ];
    })
  ]);
}
