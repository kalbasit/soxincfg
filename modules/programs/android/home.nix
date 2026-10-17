{ config, lib, ... }:

let
  cfg = config.soxincfg.programs.android;
in
{
  imports = [ ./options.nix ];

  config = lib.mkIf cfg.enable { soxincfg.settings.users.groups = lib.singleton "adbusers"; };
}
