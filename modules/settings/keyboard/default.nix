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

      # Force the actual keyboard layout to be standard QWERTY.
      # This is really annoying but neither my keyboard (ErgoDox EZ) nor my
      # Onlykey support Colemak keymap so they're configured to write in US
      # layout but I still need NeoVim and everything else to configure
      # themselves as if it's Colemak layout as they rely on Soxin's
      # configuration for that.
      home.keyboard.variant = mkForce "";
    }))

    (optionalAttrs (mode == "NixOS") (mkIf cfg.zsa.enable {
      hardware.keyboard.zsa.enable = true;

      # Force the actual keyboard layout to be standard QWERTY.
      # This is really annoying but neither my keyboard (ErgoDox EZ) nor my
      # Onlykey support Colemak keymap so they're configured to write in US
      # layout but I still need NeoVim and everything else to configure
      # themselves as if it's Colemak layout as they rely on Soxin's
      # configuration for that.
      services.xserver.xkbVariant = mkForce "";
      console.keyMap = mkForce "us";
    }))
  ]);
}
