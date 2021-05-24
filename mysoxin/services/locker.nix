{ mode, config, pkgs, lib, ... }:

with lib;
let
  cfg = config.soxin.services.locker;
in
{
  options = {
    soxin.services.locker = {
      enable = mkEnableOption "Whether to enable a screen locker.";

      executable = mkOption {
        type = types.str;
        default = "${pkgs.i3lock-color}/bin/i3lock-color";
        description = "The screen-locker executable";
      };

      color = mkOption {
        type = with types; nullOr (strMatching "^([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$");
        default = null;
        example = "606060";
        description = "The color of the screen locker.";
      };

      extraArgs = mkOption {
        type = with types; listOf str;
        default = [ ];
        example = [ "--clock" ];
        description = "Extra commands given to the screen locker.";
      };

      inactiveInterval = mkOption {
        type = types.int;
        default = 15;
        description = ''
          Inactive time interval in minutes after which session will be locked.
          The minimum is 1 minute, and the maximum is 1 hour.
        '';
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      soxin.services.locker.extraArgs = optionals (cfg.color != null) [
        "--color=${cfg.color}"
      ];
    }

    (optionalAttrs (mode == "home-manager") {
      services.screen-locker = {
        enable = true;
        inherit (cfg) inactiveInterval;
        lockCmd =
          let
            lockScript = pkgs.writeShellScript "lock.sh" ''
              ${cfg.executable} ${concatStringsSep " " cfg.extraArgs}
            '';
          in
          "${lockScript}";
      };
    })
  ]);
}
