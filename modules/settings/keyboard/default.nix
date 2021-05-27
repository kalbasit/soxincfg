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

    (optionalAttrs (mode == "home-manager") (mkIf cfg.zsa.enable  {
      home.packages = with pkgs; [ wally-cli ];
    }))

    (optionalAttrs (mode == "NixOS") (mkIf cfg.zsa.enable  {
      hardware.keyboard.zsa.enable = true;
      services.udev.packages = singleton pkgs.zsa-auto-us-layout-switcher;

      systemd.services.zsa-auto-us-layout-switcher =
        let
          auto-switcher-start = pkgs.writeShellScript "zsa-auto-us-layout-switcher-start" ''
            set -euo pipefail

            log() {
              >&2 echo "[zsa-auto-us-layout-switcher] $@"
            }

            log "Setting the keyboard layout to colemak"
            setxkbmap -layout us -variant colemak

            log "Setting up the options"
            setxkbmap -option ctrl:nocaps

            zsa_id=
            retries=0

            while [[ -z "$zsa_id" ]] && [[ $retries -lt 20 ]]; do
              log "Getting the ID of the keyboard"
              zsa_id="$( xinput list | grep 'ZSA Technology Labs Inc ErgoDox EZ Glow' | grep keyboard | grep -v 'Glow Consumer\|Glow System\|Glow Keyboard' | awk -F'=' '{print $2}' | awk '{print $1}' || true )"
              retries=$(( retries + 1 ))
              sleep 1
            done

            if [[ -n "$zsa_id" ]]; then
              log "Setting up the US layout onto the keyboard $zsa_id"
              setxkbmap -device "$zsa_id" -layout us
            else
              log "No ID were found for the ErgoDox EZ Glow"
              exit 1
            fi
          '';

          auto-switcher-stop = pkgs.writeShellScript "zsa-auto-us-layout-switcher-start" ''
            set -euo pipefail

            log() {
              >&2 echo "[zsa-auto-us-layout-switcher] $@"
            }

            log "Setting the keyboard layout to colemak"
            setxkbmap -layout us -variant colemak

            log "Setting up the options"
            setxkbmap -option ctrl:nocaps
          '';
        in {
          after = [ "graphical-session.target" ];

          environment = {
            # TODO: This should be customizable
            Xauthority = "/yl/.Xauthority";
            # TODO: This should be customizable
            DISPLAY = ":0";
          };

          path = with pkgs; [ gawk xorg.xinput xorg.setxkbmap ];

          serviceConfig = {
            ExecStart = auto-switcher-start;
            ExecStop = auto-switcher-stop;
            RemainAfterExit = true;
            Type = "oneshot";
            # TODO: This should be customizable
            User = "yl";
          };
      };
    }))
  ]);
}
