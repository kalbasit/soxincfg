{ config, lib, ... }:

let
  cfg = config.soxincfg.programs.android;
in
{
  imports = [ ./options.nix ];

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      { soxincfg.settings.users.groups = lib.singleton "adbusers"; }

      { programs.adb.enable = true; }
    ]
  );
}
