{ mode, config, pkgs, lib, soxincfg, ... }:

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

    (optionalAttrs (mode == "home-manager") (mkIf cfg.zsa.enable {
      home.packages = with pkgs; [ wally-cli ];
    }))

    (optionalAttrs (mode == "NixOS") (mkIf cfg.zsa.enable {
      hardware.keyboard.zsa.enable = true;
    }))
  ]);
}
