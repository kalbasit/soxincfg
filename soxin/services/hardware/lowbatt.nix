{ config, pkgs, lib, mode, ... }:

with lib;
let
  cfg = config.soxin.hardware.lowbatt;

  script = pkgs.writeShellScriptBin "lowbatt" ''
    function notify() {
      ${pkgs.libnotify}/bin/notify-send \
        --urgency=critical \
        --hint=int:transient:1 \
        --icon=battery_empty \
        "$1" "$2"
    }

    for device in ${cfg.devices}; do
      battery_capacity=$(${pkgs.coreutils}/bin/cat /sys/class/power_supply/$device/capacity)
      battery_status=$(${pkgs.coreutils}/bin/cat /sys/class/power_supply/$device/status)

      if [[ $battery_status != "Discharging" ]]; then
        continue
      fi

      if [[ $battery_capacity -le ${cfg.notifyCapacity} ]]; then
        notify "Battery Low" "You should probably plug-in."
      fi

      if [[ $battery_capacity -le ${cfg.hibernateCapacity} ]]; then
        notify "Battery Critically Low" "Computer will hibernate in 60 seconds."

        sleep 60

        battery_status=$(${pkgs.coreutils}/bin/cat /sys/class/power_supply/$device/status)
        if [[ $battery_status = "Discharging" ]]; then
          systemctl hibernate
        fi
      fi
    done
  '';
in
{
  options.soxin.hardware.lowbatt = {
    enable = mkEnableOption "Whether to enable battery notifier.";

    devices = mkOption {
      type = with types; listOf str;
      default = [ "BAT0" ];
      description = ''
        Devices to monitor.
      '';
      apply = value: concatStringsSep " " value;
    };

    notifyCapacity = mkOption {
      default = 10;
      description = ''
        Battery level at which a notification shall be sent.
      '';
      apply = value: toString value;
    };

    hibernateCapacity = mkOption {
      default = 5;
      description = ''
        Battery level at which a hibernate unless connected shall be sent.
      '';
      apply = value: toString value;
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (optionalAttrs (mode == "home-manager") {
      systemd.user.timers."lowbatt" = {
        Unit = {
          Description = "check battery level";
        };

        Timer = {
          OnBootSec = "1m";
          OnUnitInactiveSec = "1m";
          Unit = "lowbatt.service";
        };

        Install = {
          WantedBy = [ "timers.target" ];
        };
      };

      systemd.user.services."lowbatt" = {
        Unit = {
          Description = "battery level notifier";
        };

        Service = {
          PassEnvironment = "DISPLAY";
          ExecStart = "${script}/bin/lowbatt";
        };
      };
    })
  ]);
}
